"""Assemble binary SDK distributions from hash-pinned public bases and binary overlays."""
from pathlib import Path, PurePosixPath
from concurrent.futures import ThreadPoolExecutor
import hashlib,json,os,shutil,subprocess,sys,tarfile,urllib.request,zipfile

work=Path(sys.argv[1]).resolve();inputs=work/'inputs';plan=json.loads((inputs/'plan.json').read_text());version=plan['version'];bases={}
def sha(path):
 with path.open('rb') as stream:return hashlib.file_digest(stream,'sha256').hexdigest()
def write(path,value):
 path.parent.mkdir(parents=True,exist_ok=True);path.write_text(json.dumps(value,indent=2)+'\n')
def relative(name):
 p=PurePosixPath(name)
 if not name or p.is_absolute() or '..' in p.parts or '\\' in name:raise ValueError('unsafe payload path')
 return Path(name)
def download(url,path,expected,headers=None):
 with urllib.request.urlopen(urllib.request.Request(url,headers=headers or {}),timeout=180) as response,path.open('wb') as stream:shutil.copyfileobj(response,stream,1024*1024)
 if sha(path)!=expected:raise ValueError('download SHA-256 mismatch: '+path.name)
def unpack(record,upstream=False):
 key=record['key'];archive=work/(key+('.tgz' if upstream else '.zip' if key.startswith('windows') else '.tgz'));dest=work/'bases'/key;dest.mkdir(parents=True)
 url=record.get('url');headers={}
 if upstream:
  token=json.load(urllib.request.urlopen('https://ghcr.io/token?service=ghcr.io&scope=repository:homebrew/core/'+key+':pull'))['token']
  url='https://ghcr.io/v2/homebrew/core/'+key+'/blobs/sha256:'+record['sha256'];headers={'Authorization':'Bearer '+token}
 download(url,archive,record['sha256'],headers)
 if zipfile.is_zipfile(archive):
  with zipfile.ZipFile(archive) as z:
   for name in z.namelist():relative(name)
   z.extractall(dest)
 else:
  with tarfile.open(archive) as t:t.extractall(dest,filter='data')
 archive.unlink();print('BASE verified',key,flush=True);return key,dest/record['root']
with ThreadPoolExecutor(max_workers=3) as pool:
 for key,path in pool.map(lambda row:unpack(*row),[(r,False) for r in plan['archives']]+[(r,True) for r in plan['upstream']]):bases[key]=path
ar=bases['linux-x86_64']/'hosts/linux-x86_64/llvm/bin/llvm-ar';ar.chmod(0o755)
def inventory(root,skip):
 return [{'path':p.relative_to(root).as_posix(),'bytes':p.stat().st_size,'sha256':sha(p),'executable':bool(p.stat().st_mode&0o111)} for p in sorted(root.rglob('*')) if p.is_file() and p!=root/skip]
def assemble(sdk):
 host=sdk['host'];root=work/'payload'/('nyra-sdk-'+version+'-'+host);root.mkdir(parents=True);merged=False
 for row in sdk['files']:
  target=root/relative(row['path']);target.parent.mkdir(parents=True,exist_ok=True)
  if 'merge' in row:
   commands=['CREATE '+str(target)]+['ADDLIB '+str(bases['llvm']/'lib'/name) for name in row['merge']]+['SAVE','END']
   subprocess.run([str(ar),'--format=darwin','-M'],input='\n'.join(commands)+'\n',text=True,check=True);merged=True
  elif 'base' in row:shutil.copyfile(bases[row['base'][0]]/relative(row['base'][1]),target)
  else:
   prior=bases[row['prior'][0]]/relative(row['prior'][1]) if row['prior'] else None
   with target.open('wb') as stream:
    for chunk in row['chunks']:
     if 'blob' in chunk:
      blob=inputs/'blobs'/chunk['blob']
      if sha(blob)!=chunk['blob']:raise ValueError('overlay blob hash mismatch')
      stream.write(blob.read_bytes())
     else:
      with prior.open('rb') as old:old.seek(chunk['offset']);stream.write(old.read(chunk['bytes']))
  target.chmod(0o755 if row['executable'] else 0o644)
  if 'merge' not in row and sha(target)!=row['sha256']:raise ValueError('assembled file hash mismatch: '+row['path'])
 manifest=json.loads((root/'manifest.json').read_text());kit=root/manifest['llvm']['path']
 if merged:
  llvm=json.loads((kit/'llvm-manifest.json').read_text());llvm['files']=inventory(kit,'llvm-manifest.json');write(kit/'llvm-manifest.json',llvm)
  manifest['llvm']['manifest_sha256']=sha(kit/'llvm-manifest.json')
 manifest['files']=inventory(root,'manifest.json');write(root/'manifest.json',manifest)
 assert manifest['acceptance']=={'fixed_point':False,'full_regression':False,'full_unit':False}
 for row in manifest['targets']+manifest.get('runtime_targets',[]):
  assert {p['name'] for p in row['packages']}==({'kernel'} if row.get('hosted') is False else {'kernel','ntest','stdlib'})
 assert not any('/json/' in f['path'] or '/yaml/' in f['path'] or f['path'].endswith('.go') for f in manifest['files'])
 dist=work/'output';dist.mkdir(exist_ok=True);archive=dist/(root.name+('.zip' if host.startswith('windows') else '.tar.gz'))
 if host.startswith('windows'):
  with zipfile.ZipFile(archive,'w',compression=zipfile.ZIP_DEFLATED,compresslevel=6) as z:
   for p in sorted(root.rglob('*')):
    if p.is_file():z.write(p,p.relative_to(root.parent))
 else:
  with tarfile.open(archive,'w:gz',compresslevel=6) as t:t.add(root,arcname=root.name)
 receipt={'version':version,'host':host,'validation_scope':'packaging-only','archive':archive.name,'archive_sha256':sha(archive),'archive_bytes':archive.stat().st_size,'sdk_manifest_sha256':sha(root/'manifest.json'),'signing':'unsigned-unnotarized' if host.startswith('darwin') else 'unsigned','tools':manifest['tools'],'minimum_os_version':manifest.get('minimum_os_version'),'packages':['kernel','ntest','stdlib'],'target_profiles':len(manifest['targets']+manifest.get('runtime_targets',[])),'llvm_static_archive_reassembled':merged}
 write(dist/('release-'+host+'.json'),receipt);print('SDK packaged',host,receipt['archive_sha256'],flush=True);return receipt
with ThreadPoolExecutor(max_workers=2) as pool:receipts=list(pool.map(assemble,plan['sdks']))
dist=work/'output';write(dist/'release.json',{'schema_version':1,'version':version,'validation_scope':'packaging-only','repository':'https://github.com/nylang/sdk','releases':receipts})
write(dist/'packaging.json',{'schema_version':1,'version':version,'scope':'packaging-only','inputs_sha256':os.environ['INPUT_SHA256'],'checks':['pinned public archive hashes','overlay and reconstructed file hashes','SDK package closure','compiler source absent'],'full_regression':'not run','full_unit':'not run','bootstrap_generations':'not run','intel_execution':'not run','macos_14_execution':'not run','signing':'macOS ad-hoc only; no Developer ID/notarization; Windows unsigned'})
(dist/'SHA256SUMS').write_text(''.join(sha(p)+'  '+p.name+'\n' for p in sorted(dist.iterdir()) if p.name!='SHA256SUMS'))
assert len(list(dist.iterdir()))==11
