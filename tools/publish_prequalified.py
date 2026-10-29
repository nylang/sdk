"""Publish only the frozen 1.0.4 public assets using this repository's token.

Input URLs grant temporary access to CI artifacts containing only these public
binary distributions. No compiler source, source credential or PAT is accepted.
"""
from pathlib import Path
import hashlib, http.client, json, os, re, ssl, stat, tarfile
import urllib.request, urllib.parse, urllib.error, zipfile

ROOT = Path(__file__).resolve().parent

def sha(path):
    with Path(path).open('rb') as stream:
        return hashlib.file_digest(stream, 'sha256').hexdigest()

def write(path, value):
    Path(path).write_text(json.dumps(value, indent=2) + '\n')

class Github:
    def __init__(self, repository, token):
        self.repository = repository
        self.token = token

    def api(self, suffix, payload=None, method=None):
        request = urllib.request.Request('https://api.github.com/repos/' + self.repository + suffix,
            data=json.dumps(payload).encode() if payload is not None else None, method=method,
            headers={'Authorization': 'Bearer ' + self.token, 'Accept': 'application/vnd.github+json',
                     'Content-Type': 'application/json', 'User-Agent': 'Nyra-SDK-release'})
        try:
            with urllib.request.urlopen(request, timeout=60) as response:
                data = response.read()
                return json.loads(data) if data else None
        except urllib.error.HTTPError as error:
            try:
                message = json.loads(error.read()).get('message', '')
            except (ValueError, UnicodeError):
                message = ''
            finally:
                error.close()
            required = error.headers.get('X-Accepted-GitHub-Permissions', '')
            details = ' '.join(str(message).split())[:1000]
            if required:
                details += ' (required permissions: ' + required + ')'
            if details:
                error.msg = str(error.msg) + ': ' + details
            raise

    def upload(self, release, file):
        url = urllib.parse.urlsplit(release['upload_url'].split('{', 1)[0])
        if url.scheme != 'https' or url.hostname != 'uploads.github.com':
            raise ValueError('unexpected release upload endpoint')
        connection = http.client.HTTPSConnection(url.hostname, timeout=600, context=ssl.create_default_context())
        try:
            endpoint = url.path + '?' + urllib.parse.urlencode({'name': file.name})
            connection.putrequest('POST', endpoint)
            connection.putheader('Authorization', 'Bearer ' + self.token)
            connection.putheader('User-Agent', 'Nyra-SDK-release')
            connection.putheader('Content-Type', 'application/octet-stream')
            connection.putheader('Content-Length', str(file.stat().st_size))
            connection.endheaders()
            with file.open('rb') as stream:
                for chunk in iter(lambda: stream.read(1024 * 1024), b''):
                    connection.send(chunk)
            response = connection.getresponse()
            body = response.read()
            if response.status != 201:
                raise RuntimeError('SDK upload rejected with HTTP ' + str(response.status))
            return json.loads(body)
        finally:
            connection.close()


def find_release(github, tag):
    """Find published versions or a unique draft without creating duplicates."""
    try:
        return github.api('/releases/tags/' + urllib.parse.quote(tag, safe=''))
    except urllib.error.HTTPError as error:
        if error.code != 404:
            raise
        error.close()
    # The by-tag endpoint returns published releases. Drafts require listing
    # releases with an authenticated actor that has access to the draft.
    matches = []
    page = 1
    while True:
        rows = github.api('/releases?per_page=100&page=' + str(page))
        matches.extend(row for row in rows if row['tag_name'] == tag)
        if len(rows) < 100:
            break
        page += 1
    if len(matches) > 1:
        raise ValueError('multiple releases use this tag; inspect before retrying')
    return matches[0] if matches else None


plan = json.loads((ROOT / 'prequalified-1.0.4.json').read_text())
expected = {r['name']: r for r in plan['assets']}
directory = Path('publication-input')
directory.mkdir(exist_ok=False)
urls = json.loads(os.environ['PUBLIC_ARTIFACT_URLS'])
if not isinstance(urls, list) or len(urls) != 4:
    raise ValueError('four source-free artifact URLs required')
for index, url in enumerate(urls):
    parsed = urllib.parse.urlsplit(url)
    if parsed.scheme != 'https' or not parsed.hostname.endswith('.blob.core.windows.net'):
        raise ValueError('unexpected artifact download endpoint')
    archive = Path('artifact-' + str(index) + '.zip')
    with urllib.request.urlopen(url, timeout=300) as source, archive.open('wb') as target:
        import shutil
        shutil.copyfileobj(source, target)
    with zipfile.ZipFile(archive) as source:
        for row in source.infolist():
            if row.filename not in expected or row.is_dir() or stat.S_ISLNK(row.external_attr >> 16):
                raise ValueError('unapproved artifact entry')
            path = directory / row.filename
            if path.exists() or row.file_size != expected[row.filename]['bytes']:
                raise ValueError('duplicate or incorrect artifact file')
            with source.open(row) as content, path.open('wb') as target:
                shutil.copyfileobj(content, target)
    archive.unlink()
if {p.name for p in directory.iterdir()} != set(expected):
    raise ValueError('missing prequalified release assets')
for name, row in expected.items():
    path = directory / name
    if sha(path) != row['sha256'] or path.stat().st_size != row['bytes']:
        raise ValueError('prequalified asset changed: ' + name)

if True:
    github = Github('nylang/sdk', os.environ['GH_TOKEN'])
    release = find_release(github, 'v1.0.4')
    if release is None:
        release = github.api('/releases', dict(tag_name='v1.0.4', target_commitish=plan['public_commit'], name='Nyra SDK 1.0.4', body=plan['body'], draft=True, prerelease=False))
    if release['body'] != plan['body'] or release['prerelease']:
        raise ValueError('existing release belongs to another plan')
    assets = {r['name']: r for r in github.api('/releases/' + str(release['id']) + '/assets?per_page=100')}
    if set(assets) - set(expected):
        raise ValueError('unexpected remote assets')
    for name, row in expected.items():
        asset = assets.get(name)
        if asset and asset['state'] == 'starter' and release['draft']:
            github.api('/releases/assets/' + str(asset['id']), method='DELETE')
            asset = None
        if asset is None:
            if not release['draft']:
                raise ValueError('published releases are immutable')
            print('Uploading ' + name, flush=True)
            asset = github.upload(release, directory / name)
        if asset.get('state') != 'uploaded' or asset['size'] != row['bytes'] or asset.get('digest') != 'sha256:' + row['sha256']:
            raise ValueError('remote asset digest mismatch: ' + name)
    remote = github.api('/releases/' + str(release['id']) + '/assets?per_page=100')
    if len(remote) != len(expected) or {r['name'] for r in remote} != set(expected):
        raise ValueError('incomplete remote inventory')
    for asset in remote:
        row = expected[asset['name']]
        if asset['size'] != row['bytes'] or asset.get('digest') != 'sha256:' + row['sha256']:
            raise ValueError('remote asset changed before publication')
    if release['draft']:
        release = github.api('/releases/' + str(release['id']), {'draft': False}, method='PATCH')
    if release['draft']:
        raise ValueError('publication unconfirmed')
    write(Path('publication.json'), dict(status='published', version='1.0.4', url=release['html_url'],
          published_at=release['published_at'], source_commit=plan['source_commit'],
          qualification='prequalified-existing-1.0.4', compiler_rebuilt=False, complete_suites_repeated=False,
          assets=[{k: a[k] for k in ('id', 'name', 'size', 'digest', 'browser_download_url')} for a in remote]))
    print('Published ' + release['html_url'])
