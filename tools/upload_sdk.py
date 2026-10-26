"""Upload packaging outputs to the explicitly selected draft; never publish it."""
from pathlib import Path
import hashlib,json,os,sys,urllib.request,urllib.parse
root=Path(sys.argv[1]);release_id=int(sys.argv[2]);repo=os.environ['GITHUB_REPOSITORY'];api='https://api.github.com/repos/'+repo
headers={'Authorization':'Bearer '+os.environ['GH_TOKEN'],'Accept':'application/vnd.github+json','User-Agent':'Nyra-SDK-packaging'}
def call(path,method='GET'):
 with urllib.request.urlopen(urllib.request.Request(api+path,headers=headers,method=method),timeout=120) as response:
  return json.load(response) if response.status!=204 else None
def check_draft():
 release=call('/releases/'+str(release_id))
 if not release['draft'] or release['tag_name']!='v'+os.environ['VERSION']:raise ValueError('release is no longer the selected draft')
 return release
release=check_draft();assets={x['name']:x for x in call('/releases/'+str(release_id)+'/assets?per_page=100')}
for path in sorted(root.iterdir()):
 if not path.is_file():continue
 with path.open('rb') as stream:sha=hashlib.file_digest(stream,'sha256').hexdigest()
 check_draft()
 if path.name in assets:
  asset=assets[path.name]
  if asset.get('digest')=='sha256:'+sha:continue
  call('/releases/assets/'+str(asset['id']),'DELETE')
 def chunks():
  with path.open('rb') as stream:
   while chunk:=stream.read(1024*1024):yield chunk
 endpoint=release['upload_url'].split('{')[0]+'?name='+urllib.parse.quote(path.name)
 req=urllib.request.Request(endpoint,data=chunks(),headers=headers|{'Content-Type':'application/octet-stream','Content-Length':str(path.stat().st_size)},method='POST')
 with urllib.request.urlopen(req,timeout=180) as response:asset=json.load(response)
 if asset.get('digest')!='sha256:'+sha or asset['size']!=path.stat().st_size:raise ValueError('server digest mismatch: '+path.name)
 print('Uploaded and verified',path.name,sha,flush=True)
