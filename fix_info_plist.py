#!/usr/bin/env python3

import os
import plistlib
import re
import shutil
import sys

def main():
    project_file = "BreadCrumb.xcodeproj/project.pbxproj"
    
    # Backup the project file
    backup_file = f"{project_file}.bak"
    print(f"Creating backup at {backup_file}")
    shutil.copy2(project_file, backup_file)
    
    # Read the project file
    try:
        with open(project_file, 'rb') as f:
            project_data = plistlib.load(f)
    except:
        print("Failed to read project file as plist. Trying alternate approach...")
        
        # Read the file as text and modify it directly
        with open(project_file, 'r') as f:
            content = f.read()
        
        # Prepare a pattern to match the Info.plist in Copy Bundle Resources
        pattern1 = r'(\/\* Begin PBXCopyFilesBuildPhase section \*\/.*?\/\* End PBXCopyFilesBuildPhase section \*\/)'
        pattern2 = r'(\/\* Begin PBXResourcesBuildPhase section \*\/.*?\/\* End PBXResourcesBuildPhase section \*\/)'
        
        # Look for any references to Info.plist in the file references
        info_plist_pattern = r'([A-F0-9]{24})\s*\/\* Info\.plist \*\/'
        info_plist_refs = re.findall(info_plist_pattern, content, re.DOTALL)
        
        if info_plist_refs:
            print(f"Found Info.plist references: {info_plist_refs}")
            
            # Now look for these references in the build phases
            for ref in info_plist_refs:
                ref_pattern = re.compile(r'(\s*' + ref + r'\s*\/\* Info\.plist in Resources \*\/\s*,)')
                
                # Replace in resources build phase
                resources_section = re.search(pattern2, content, re.DOTALL)
                if resources_section:
                    resources_content = resources_section.group(1)
                    modified_resources = re.sub(ref_pattern, '', resources_content)
                    content = content.replace(resources_content, modified_resources)
                    
                    print("Modified Resources build phase")
        
        # Add extra build settings to ensure Info.plist is handled correctly
        settings_pattern = r'(GENERATE_INFOPLIST_FILE\s*=\s*NO\s*;)'
        replace_with = r'\1\n				PLIST_FILE_OUTPUT_FORMAT = xml;\n				INFOPLIST_OUTPUT_FORMAT = xml;\n				DONT_GENERATE_INFOPLIST_FILE = YES;'
        content = re.sub(settings_pattern, replace_with, content)
        
        # Write the modified content back
        with open(project_file, 'w') as f:
            f.write(content)
            
        print("Project file updated. Try building again.")
        return 0
        
    # If we got here, the plistlib approach worked
    # Implement the plist modification logic here if needed
    
    return 0

if __name__ == "__main__":
    sys.exit(main()) 