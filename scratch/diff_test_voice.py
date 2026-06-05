import os
import winreg
import json
import re

def main():
    try:
        hkey = winreg.OpenKey(winreg.HKEY_CURRENT_USER, r"Software\Valve\Steam")
        steam_path, _ = winreg.QueryValueEx(hkey, "SteamPath")
        winreg.CloseKey(hkey)
        steam_path = os.path.abspath(steam_path)
    except Exception:
        steam_path = r"C:\Program Files (x86)\Steam"
    
    print("Steam Path:", steam_path)
    
    userdata_path = os.path.join(steam_path, "userdata")
    if not os.path.exists(userdata_path):
        print("No userdata folder found.")
        return
        
    for root_dir, dirs, files in os.walk(userdata_path):
        for file in files:
            if file == "localconfig.vdf":
                path = os.path.join(root_dir, file)
                print(f"\n--- Checking {path} ---")
                try:
                    with open(path, "r", encoding="utf-8", errors="ignore") as f:
                        content = f.read()
                    
                    # Pattern that correctly matches escaped quotes inside double quotes
                    pattern = r'"SteamVoiceSettings_(\d+)"\s+"((?:[^"\\]|\\.)*)"'
                    matches = re.findall(pattern, content)
                    if not matches:
                        print("No SteamVoiceSettings found in this file.")
                    else:
                        for steam_id, escaped_json in matches:
                            print(f"\n[Steam ID: {steam_id}]")
                            clean_json = escaped_json.replace('\\"', '"').replace('\\\\', '\\')
                            try:
                                settings = json.loads(clean_json)
                                print("Voice Settings:")
                                print(json.dumps(settings, indent=4, ensure_ascii=False))
                            except Exception as json_err:
                                print(f"Failed to parse JSON: {json_err}")
                                print(f"Raw clean JSON: {clean_json}")
                except Exception as e:
                    print("Error reading file:", e)

if __name__ == "__main__":
    main()
