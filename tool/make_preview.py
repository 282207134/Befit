"""Arrange genuine emulator screenshots for documentation and visual review."""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
SHOTS = ROOT / 'docs' / 'screenshots'
FONT = ImageFont.truetype('C:/Windows/Fonts/segoeui.ttf', 15)


def sheet(names, output, columns=4, width=230):
    height = round(width * 2340 / 1080)
    rows = (len(names) + columns - 1) // columns
    board = Image.new('RGB', (columns * (width + 22) + 22,
                             rows * (height + 48) + 22), '#141127')
    draw = ImageDraw.Draw(board)
    for i, name in enumerate(names):
        x, y = 22 + i % columns * (width + 22), 22 + i // columns * (height + 48)
        with Image.open(SHOTS / name) as source:
            board.paste(source.convert('RGB').resize((width, height), Image.Resampling.LANCZOS), (x, y))
        draw.text((x, y + height + 8), Path(name).stem, fill='#d2cfee', font=FONT)
    board.save(output, quality=92)


if __name__ == '__main__':
    files = sorted(p.name for p in SHOTS.glob('*.png') if p.name[0].isdigit())
    for page, start in enumerate(range(0, len(files), 10), 1):
        sheet(files[start:start + 10], ROOT / 'tool' / f'qa_{page}.jpg')
    sheet(['06_home.png', '09_club.png', '15_challenges.png',
           '17_daily.png', '19_workout.png', '30_profile.png'],
          SHOTS / 'overview.jpg', columns=3, width=260)
