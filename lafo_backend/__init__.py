from pathlib import Path

_backend_package = Path(__file__).resolve().parent.parent / "backend" / "lafo_backend"
if _backend_package.exists():
    __path__.append(str(_backend_package))
