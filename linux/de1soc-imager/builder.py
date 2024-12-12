#!/usr/bin/env python3

from pathlib import Path
from dataclasses import dataclass
import shutil

@dataclass
class BuildConfig:
    build_root: Path
    keep_build: bool = False

    def __post_init__(self):
        self.build_root = Path(self.build_root).absolute()
        self.build_root.mkdir(parents=True, exist_ok=True)

class Builder:
    def __init__(self, config: BuildConfig):
        self.config = config
        
    def get_build_dir(self, component: str) -> Path:
        build_dir = self.config.build_root / component
        build_dir.mkdir(parents=True, exist_ok=True)
        return build_dir
        
    def cleanup(self):
        if not self.config.keep_build:
            shutil.rmtree(self.config.build_root, ignore_errors=True)
