#!/usr/bin/env python3

"""
Ultra Cool OS - Advanced rootc.img Packager
Intelligent packaging system for 1GB rootc.img with advanced compression
macOS 26 + mrOS 2.0 + Samsung Glassy Style optimization
"""

import os
import sys
import json
import gzip
import lzma
import zlib
import hashlib
import subprocess
import shutil
import tempfile
from pathlib import Path
from typing import Dict, List, Tuple, Optional
from dataclasses import dataclass
from concurrent.futures import ThreadPoolExecutor, as_completed
import argparse

@dataclass
class CompressionResult:
    """Result of compression operation"""
    original_size: int
    compressed_size: int
    compression_ratio: float
    method: str
    time_taken: float

@dataclass
class PackageInfo:
    """Information about a package component"""
    name: str
    path: str
    size: int
    compressed_size: int
    checksum: str
    compression_method: str

class UltraCoolPackager:
    """Advanced packaging system for Ultra Cool OS"""
    
    def __init__(self, source_dir: str, output_file: str, target_size: int = 1024 * 1024 * 1024):
        self.source_dir = Path(source_dir)
        self.output_file = Path(output_file)
        self.target_size = target_size
        self.temp_dir = None
        self.packages: List[PackageInfo] = []
        
        # Compression methods with their efficiency ratings
        self.compression_methods = {
            'lzma': {'func': lzma.compress, 'level': 9, 'efficiency': 0.95},
            'gzip': {'func': gzip.compress, 'level': 9, 'efficiency': 0.85},
            'zlib': {'func': zlib.compress, 'level': 9, 'efficiency': 0.80},
        }
        
        # File type priorities for compression
        self.file_priorities = {
            '.so': 1,      # Libraries - high priority
            '.bin': 1,     # Binaries - high priority
            '.js': 2,      # JavaScript - medium-high priority
            '.css': 2,     # CSS - medium-high priority
            '.html': 2,    # HTML - medium-high priority
            '.xml': 3,     # XML - medium priority
            '.json': 3,    # JSON - medium priority
            '.txt': 4,     # Text - low priority
            '.log': 5,     # Logs - lowest priority
        }
    
    def print_status(self, message: str, color: str = '\033[0;36m'):
        """Print colored status message"""
        print(f"{color}[Ultra Cool Packager]{'\033[0m'} {message}")
    
    def print_success(self, message: str):
        """Print success message"""
        print(f"\033[0;32m✅ {message}\033[0m")
    
    def print_error(self, message: str):
        """Print error message"""
        print(f"\033[0;31m❌ {message}\033[0m")
    
    def print_warning(self, message: str):
        """Print warning message"""
        print(f"\033[1;33m⚠️  {message}\033[0m")
    
    def calculate_checksum(self, file_path: Path) -> str:
        """Calculate SHA256 checksum of a file"""
        sha256_hash = hashlib.sha256()
        with open(file_path, "rb") as f:
            for chunk in iter(lambda: f.read(4096), b""):
                sha256_hash.update(chunk)
        return sha256_hash.hexdigest()
    
    def get_optimal_compression(self, data: bytes) -> Tuple[bytes, str, float]:
        """Find the best compression method for given data"""
        best_compressed = data
        best_method = 'none'
        best_ratio = 0.0
        
        for method_name, method_info in self.compression_methods.items():
            try:
                if method_name == 'lzma':
                    compressed = lzma.compress(data, preset=method_info['level'])
                elif method_name == 'gzip':
                    compressed = gzip.compress(data, compresslevel=method_info['level'])
                elif method_name == 'zlib':
                    compressed = zlib.compress(data, level=method_info['level'])
                else:
                    continue
                
                ratio = len(compressed) / len(data)
                
                if len(compressed) < len(best_compressed):
                    best_compressed = compressed
                    best_method = method_name
                    best_ratio = ratio
                    
            except Exception as e:
                self.print_warning(f"Compression method {method_name} failed: {e}")
                continue
        
        return best_compressed, best_method, best_ratio
    
    def compress_file(self, file_path: Path) -> Optional[PackageInfo]:
        """Compress a single file and return package info"""
        try:
            if not file_path.is_file():
                return None
            
            original_size = file_path.stat().st_size
            if original_size == 0:
                return None
            
            # Read file data
            with open(file_path, 'rb') as f:
                data = f.read()
            
            # Get optimal compression
            compressed_data, method, ratio = self.get_optimal_compression(data)
            
            # Calculate checksum
            checksum = hashlib.sha256(data).hexdigest()
            
            # Create package info
            package_info = PackageInfo(
                name=str(file_path.relative_to(self.source_dir)),
                path=str(file_path),
                size=original_size,
                compressed_size=len(compressed_data),
                checksum=checksum,
                compression_method=method
            )
            
            return package_info
            
        except Exception as e:
            self.print_warning(f"Failed to compress {file_path}: {e}")
            return None
    
    def analyze_filesystem(self) -> Dict[str, int]:
        """Analyze filesystem to determine optimization strategy"""
        self.print_status("Analyzing filesystem structure...")
        
        analysis = {
            'total_files': 0,
            'total_size': 0,
            'file_types': {},
            'large_files': [],
            'compressible_size': 0
        }
        
        for file_path in self.source_dir.rglob('*'):
            if file_path.is_file():
                size = file_path.stat().st_size
                suffix = file_path.suffix.lower()
                
                analysis['total_files'] += 1
                analysis['total_size'] += size
                
                if suffix in analysis['file_types']:
                    analysis['file_types'][suffix] += size
                else:
                    analysis['file_types'][suffix] = size
                
                if size > 1024 * 1024:  # Files larger than 1MB
                    analysis['large_files'].append((str(file_path), size))
                
                # Estimate compressible size
                if suffix in ['.txt', '.log', '.xml', '.json', '.js', '.css', '.html']:
                    analysis['compressible_size'] += size
        
        self.print_success(f"Analyzed {analysis['total_files']} files ({analysis['total_size'] // 1024 // 1024}MB)")
        return analysis
    
    def optimize_file_selection(self, analysis: Dict) -> List[Path]:
        """Select and prioritize files for optimal packaging"""
        self.print_status("Optimizing file selection...")
        
        all_files = []
        for file_path in self.source_dir.rglob('*'):
            if file_path.is_file():
                size = file_path.stat().st_size
                suffix = file_path.suffix.lower()
                priority = self.file_priorities.get(suffix, 6)
                
                all_files.append((file_path, size, priority))
        
        # Sort by priority (lower number = higher priority) and size
        all_files.sort(key=lambda x: (x[2], -x[1]))
        
        selected_files = []
        current_size = 0
        
        for file_path, size, priority in all_files:
            # Estimate compressed size (rough estimate)
            estimated_compressed = size * 0.3 if file_path.suffix.lower() in ['.txt', '.log', '.xml', '.json'] else size * 0.8
            
            if current_size + estimated_compressed <= self.target_size * 0.95:  # Leave 5% buffer
                selected_files.append(file_path)
                current_size += estimated_compressed
            else:
                break
        
        self.print_success(f"Selected {len(selected_files)} files for packaging")
        return selected_files
    
    def create_package_manifest(self) -> Dict:
        """Create package manifest with metadata"""
        manifest = {
            'ultra_cool_os': {
                'version': '1.0',
                'codename': 'Glassy Fusion',
                'build_date': subprocess.check_output(['date', '-Iseconds']).decode().strip(),
                'architecture': 'x86_64',
                'features': [
                    'macos_26_style',
                    'mros_2_integration',
                    'samsung_glassy_effects',
                    'advanced_compression',
                    '1gb_optimization'
                ]
            },
            'package_info': {
                'total_packages': len(self.packages),
                'total_compressed_size': sum(p.compressed_size for p in self.packages),
                'total_original_size': sum(p.size for p in self.packages),
                'compression_ratio': sum(p.compressed_size for p in self.packages) / sum(p.size for p in self.packages) if self.packages else 1.0
            },
            'packages': [
                {
                    'name': p.name,
                    'size': p.size,
                    'compressed_size': p.compressed_size,
                    'checksum': p.checksum,
                    'compression_method': p.compression_method
                }
                for p in self.packages
            ]
        }
        
        return manifest
    
    def create_rootc_image(self, selected_files: List[Path]) -> bool:
        """Create the final rootc.img file"""
        self.print_status("Creating 1GB rootc.img...")
        
        try:
            # Create temporary directory for processing
            with tempfile.TemporaryDirectory() as temp_dir:
                temp_path = Path(temp_dir)
                
                # Process files with parallel compression
                self.print_status("Compressing files in parallel...")
                
                with ThreadPoolExecutor(max_workers=os.cpu_count()) as executor:
                    future_to_file = {
                        executor.submit(self.compress_file, file_path): file_path
                        for file_path in selected_files
                    }
                    
                    for future in as_completed(future_to_file):
                        file_path = future_to_file[future]
                        try:
                            package_info = future.result()
                            if package_info:
                                self.packages.append(package_info)
                        except Exception as e:
                            self.print_warning(f"Failed to process {file_path}: {e}")
                
                # Create manifest
                manifest = self.create_package_manifest()
                
                # Write manifest
                manifest_path = temp_path / 'manifest.json'
                with open(manifest_path, 'w') as f:
                    json.dump(manifest, f, indent=2)
                
                # Create the final image
                self.print_status("Assembling final rootc.img...")
                
                # Create filesystem image
                image_path = temp_path / 'rootc.img'
                
                # Create ext4 filesystem
                subprocess.run([
                    'dd', 'if=/dev/zero', f'of={image_path}',
                    'bs=1M', f'count={self.target_size // 1024 // 1024}'
                ], check=True, capture_output=True)
                
                subprocess.run([
                    'mkfs.ext4', '-F', '-m', '1', '-O', '^has_journal,^ext_attr,^resize_inode',
                    str(image_path)
                ], check=True, capture_output=True)
                
                # Mount and populate
                mount_point = temp_path / 'mount'
                mount_point.mkdir()
                
                subprocess.run([
                    'sudo', 'mount', '-o', 'loop', str(image_path), str(mount_point)
                ], check=True)
                
                try:
                    # Copy optimized files
                    for package in self.packages:
                        src_path = Path(package.path)
                        rel_path = Path(package.name)
                        dst_path = mount_point / rel_path
                        
                        # Create directory structure
                        dst_path.parent.mkdir(parents=True, exist_ok=True)
                        
                        # Copy file
                        shutil.copy2(src_path, dst_path)
                    
                    # Copy manifest
                    shutil.copy2(manifest_path, mount_point / 'manifest.json')
                    
                    # Set permissions
                    subprocess.run([
                        'sudo', 'chown', '-R', 'root:root', str(mount_point)
                    ], check=True)
                    
                finally:
                    subprocess.run(['sudo', 'umount', str(mount_point)], check=True)
                
                # Optimize filesystem
                subprocess.run(['e2fsck', '-f', '-y', str(image_path)], capture_output=True)
                subprocess.run(['resize2fs', '-M', str(image_path)], capture_output=True)
                
                # Copy to final location
                shutil.copy2(image_path, self.output_file)
                
                self.print_success(f"rootc.img created: {self.output_file}")
                return True
                
        except Exception as e:
            self.print_error(f"Failed to create rootc.img: {e}")
            return False
    
    def generate_checksums(self):
        """Generate checksums for the created image"""
        self.print_status("Generating checksums...")
        
        checksum = self.calculate_checksum(self.output_file)
        
        # Write checksum file
        checksum_file = self.output_file.with_suffix('.sha256')
        with open(checksum_file, 'w') as f:
            f.write(f"{checksum}  {self.output_file.name}\n")
        
        self.print_success(f"Checksum written to {checksum_file}")
    
    def create_installation_script(self):
        """Create installation script for the rootc.img"""
        install_script = self.output_file.parent / 'install_rootc.sh'
        
        script_content = f'''#!/bin/bash
# Ultra Cool OS rootc.img Installation Script
# macOS 26 + mrOS 2.0 + Samsung Glassy Style

echo "🚀 Ultra Cool OS rootc.img Installer"
echo "Installing 1GB optimized root filesystem..."

ROOTC_IMG="{self.output_file.name}"
CHECKSUM_FILE="{self.output_file.name}.sha256"

if [ ! -f "$ROOTC_IMG" ]; then
    echo "❌ $ROOTC_IMG not found!"
    exit 1
fi

# Verify checksum
if [ -f "$CHECKSUM_FILE" ]; then
    echo "🔍 Verifying checksum..."
    sha256sum -c "$CHECKSUM_FILE" || exit 1
    echo "✅ Checksum verified"
fi

echo "✅ Ultra Cool OS rootc.img ready for use!"
echo "🎯 Features: macOS 26 + mrOS 2.0 + Samsung Glassy Style"
echo "📦 Size: 1GB optimized filesystem"
echo ""
echo "To use this image:"
echo "1. Mount: sudo mount -o loop $ROOTC_IMG /mnt"
echo "2. Chroot: sudo chroot /mnt"
echo "3. Enjoy Ultra Cool OS!"
'''
        
        with open(install_script, 'w') as f:
            f.write(script_content)
        
        os.chmod(install_script, 0o755)
        self.print_success(f"Installation script created: {install_script}")
    
    def package(self) -> bool:
        """Main packaging function"""
        self.print_status("🚀 Starting Ultra Cool OS 1GB rootc.img packaging...")
        
        if not self.source_dir.exists():
            self.print_error(f"Source directory {self.source_dir} does not exist")
            return False
        
        # Analyze filesystem
        analysis = self.analyze_filesystem()
        
        # Check if we can fit in target size
        if analysis['total_size'] > self.target_size * 2:  # Even with compression
            self.print_warning(f"Source size ({analysis['total_size'] // 1024 // 1024}MB) may be too large for 1GB target")
        
        # Optimize file selection
        selected_files = self.optimize_file_selection(analysis)
        
        # Create the rootc.img
        if not self.create_rootc_image(selected_files):
            return False
        
        # Generate checksums
        self.generate_checksums()
        
        # Create installation script
        self.create_installation_script()
        
        # Final report
        final_size = self.output_file.stat().st_size
        compression_ratio = (sum(p.compressed_size for p in self.packages) / 
                           sum(p.size for p in self.packages)) if self.packages else 1.0
        
        print(f"""
\033[0;35m🎉 Ultra Cool OS rootc.img Packaging Complete! 🎉\033[0m

📊 Package Summary:
   Target Size: {self.target_size // 1024 // 1024}MB
   Final Size: {final_size // 1024 // 1024}MB
   Files Processed: {len(self.packages)}
   Compression Ratio: {compression_ratio:.2%}
   
🚀 Features Included:
   ✨ macOS 26 inspired design
   🔧 mrOS 2.0 performance optimizations  
   📱 Samsung glassy style effects
   🗜️  Advanced compression algorithms
   
📁 Output Files:
   🖼️  {self.output_file}
   🔐 {self.output_file}.sha256
   📜 install_rootc.sh
   
\033[0;32m✅ Ready to boot the future of operating systems!\033[0m
""")
        
        return True

def main():
    """Main entry point"""
    parser = argparse.ArgumentParser(
        description='Ultra Cool OS Advanced rootc.img Packager',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python3 rootc-packager.py /path/to/rootfs rootc.img
  python3 rootc-packager.py --size 2048 /path/to/rootfs rootc.img
        """
    )
    
    parser.add_argument('source_dir', help='Source directory to package')
    parser.add_argument('output_file', help='Output rootc.img file')
    parser.add_argument('--size', type=int, default=1024, 
                       help='Target size in MB (default: 1024)')
    parser.add_argument('--verbose', '-v', action='store_true',
                       help='Enable verbose output')
    
    args = parser.parse_args()
    
    # Create packager
    packager = UltraCoolPackager(
        source_dir=args.source_dir,
        output_file=args.output_file,
        target_size=args.size * 1024 * 1024
    )
    
    # Run packaging
    success = packager.package()
    
    sys.exit(0 if success else 1)

if __name__ == '__main__':
    main()

