"""Build a portable source handoff without caches, unused assets or local paths."""
from pathlib import Path
import re
from zipfile import ZipFile, ZIP_DEFLATED

root = Path(__file__).resolve().parents[1]
output = root.parent / 'deliverables'
output.mkdir(exist_ok=True)
assets = set(re.findall(r'^\s*- (?:asset: )?(assets/[^\s]+)',
                        (root / 'pubspec.yaml').read_text(encoding='utf-8'), re.M))
excluded_dirs = {'.dart_tool', '.idea', '.git', '.gradle', 'build', 'build_temp',
                 'ephemeral', '.symlinks', 'Pods', '__pycache__'}
excluded_files = {'local.properties', '.flutter-plugins-dependencies',
                  'Generated.xcconfig', 'flutter_export_environment.sh'}
with ZipFile(output / 'befit_flutter_source.zip', 'w', ZIP_DEFLATED, compresslevel=6) as archive:
    count = 0
    for path in sorted(root.rglob('*')):
        if not path.is_file():
            continue
        relative = path.relative_to(root)
        name = relative.as_posix()
        if any(part in excluded_dirs for part in relative.parts) or path.name in excluded_files:
            continue
        if path.suffix in {'.log', '.iml', '.pyc'}:
            continue
        if path.name.startswith('GeneratedPluginRegistrant'):
            continue
        if name.startswith('assets/') and name not in assets:
            continue
        if name.startswith('tool/') and path.suffix != '.py':
            continue
        if name == 'docs/screenshots/preview.png':
            continue
        archive.write(path, 'befit_flutter/' + name)
        count += 1
print(f'Packaged {count} files into {output / "befit_flutter_source.zip"}')
