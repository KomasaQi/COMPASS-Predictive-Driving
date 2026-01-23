from pathlib import Path
from PIL import Image

def gif_to_infinite_loop(in_path: Path, out_path: Path):
    """
    Rewrite a GIF with infinite loop (loop=0).
    Preserve per-frame duration when available.
    """
    with Image.open(in_path) as im:
        # Ensure it's a GIF and has frames
        frames = []
        durations = []

        # Pillow lets us iterate frames by seeking
        i = 0
        while True:
            try:
                im.seek(i)
            except EOFError:
                break

            frame = im.copy()
            frames.append(frame)

            # duration is in milliseconds in Pillow
            d = im.info.get("duration", 100)  # default 100ms
            durations.append(d)
            i += 1

        if not frames:
            raise RuntimeError("No frames found.")

        out_path.parent.mkdir(parents=True, exist_ok=True)

        # Save: loop=0 means infinite loop
        # duration can be a list to preserve per-frame timing
        frames[0].save(
            out_path,
            save_all=True,
            append_images=frames[1:],
            loop=0,
            duration=durations,
            optimize=False,   # set True if you want smaller file (may be slower)
            disposal=2        # common default; helps for many GIFs
        )

def convert_all_gifs_in_cwd(out_dir="gif_infinite_py"):
    cwd = Path.cwd()
    out_dir = cwd / out_dir
    gifs = sorted(cwd.glob("*.gif"))

    if not gifs:
        print(f"[INFO] No GIF files found in: {cwd}")
        return

    for p in gifs:
        out_path = out_dir / p.name
        try:
            gif_to_infinite_loop(p, out_path)
            print(f"[OK] {p.name} -> {out_path} (loop=0)")
        except Exception as e:
            print(f"[FAIL] {p.name}: {e}")

    print(f"[DONE] Output folder: {out_dir}")

if __name__ == "__main__":
    convert_all_gifs_in_cwd()
