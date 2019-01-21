package;

import haxe.Json;
import haxe.io.Bytes;
import sys.FileSystem;
import sys.io.File;
/**
 * ...
 * @author Bioruebe
 */
class Main {
	private static var files:Array<String>;
	
	static function main() {
		Bio.Header("brunsdec", "1.0.0", "A simple decrypter for Bruns Engine encrypted files (with magic number 'EENC')", "<input_file>|<input_dir> [<output_dir>]");
		Bio.Seperator();
		
		var args = Sys.args();
		if (args.length < 1) Bio.Error("Please specify an input path. This can either be a file or a directory containing EENC files.", 1);
		Bio.PrintArray(args);
		files = readInputFileArgument(args[0]);
		var outdir = args.length > 1? Bio.AssurePathExists(Bio.PathAppendSeperator(args[1])): null;
		var deadbeef = Bio.HexToBytes("EFBEADDE");
		var iErrors = 0;
		
		for (i in 0...files.length) {
			try {
				if (FileSystem.isDirectory(files[i])) continue;
				
				var fileParts = Bio.FileGetParts(files[i]);
				var outFile = (outdir == null? fileParts.directory: outdir);
				outFile += FileSystem.exists(outFile + fileParts.fullName)? fileParts.name + ".decrypted." + fileParts.extension: fileParts.fullName;
				if (FileSystem.exists(outFile) && !Bio.Prompt("The file " + fileParts.fullName + " already exists. Overwrite?", "OutOverwrite")) {
					Bio.Cout("Skipped file " + fileParts.fullName);
					continue;
				}
				
				var bytes = File.getBytes(files[i]);
				
				var magic = bytes.getString(0, 4);
				if (magic != "EENC") {
					Bio.Cout("Skipping file '" + fileParts.fullName + "': not an encrypted Bruns Engine file");
					continue;
				}
				
				var key = bytes.sub(4, 4);
				Bio.Xor(key, deadbeef);
				var swapped = swap32(key.getInt32(0));
				Bio.Cout("Using decryption key " + key.toHex(), Bio.LogSeverity.DEBUG);
				
				bytes = bytes.sub(8, bytes.length - 8);
				Bio.Xor(bytes, key);
				
				File.saveBytes(outFile, bytes);
				Bio.Cout('${i + 1}/${files.length}\t${fileParts.fullName}');
			} catch (e:Dynamic) {
				Bio.Cout('${i + 1}/${files.length}\tFailed to read file - $e', Bio.LogSeverity.ERROR);
				iErrors += 1;
			}
		}
		
		Bio.Cout(iErrors > 0? "Operation completed with " + iErrors + " errors": "All OK");
	}
	
	private static function readInputFileArgument(file:String){
		if (!FileSystem.exists(file)) {
			Bio.Error("The input file " + file + " does not exist.", 1);
			return null;
		}
		else if (FileSystem.isDirectory(file)) {
			return FileSystem.readDirectory(file).map(function(s:String) {
				return Bio.PathAppendSeperator(file) + s;
			});
		}
		else {
			return [file];
		}
	}
	
	/**
	 * Swap endian-ness of a 32 bit value
	 * https://stackoverflow.com/a/5320624
	 * @param	val
	 */
	private static function swap32(val:Int) {
		return ((val & 0xFF) << 24)
           | ((val & 0xFF00) << 8)
           | ((val >> 8) & 0xFF00)
           | ((val >> 24) & 0xFF);
	}
}