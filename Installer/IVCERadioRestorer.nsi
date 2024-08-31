; Script to install Radio Restoration mod for GTA IV Complete Edition and to optionally install FusionFix.

VIProductVersion "1.0.0.0"
VIAddVersionKey "ProductName" "Radio Restoration mod"
VIAddVersionKey "Comments" "Mod for GTA IV CE ONLY"
VIAddVersionKey "CompanyName" "Fusion Team"
VIAddVersionKey "LegalTrademarks" "Radio Restoration mod is a trademark of Fusion Team"
VIAddVersionKey "LegalCopyright" "Copyright Fusion Team"
VIAddVersionKey "FileDescription" "Radio Restoration mod"
VIAddVersionKey "FileVersion" "1.1.0"

ManifestDPIAware true

SetCompressor lzma

Unicode True

BrandingText ""

CRCCheck on

!include FileFunc.nsh
!include LogicLib.nsh
!include NSISpcre.nsh
!include Sections.nsh
!include nsDialogs.nsh
!include MUI2.nsh

!insertmacro REMatches

; The name of the installer
Name "Radio Restoration for GTA IV Complete Edition"

; The file to write
OutFile "..\IVCERadioRestoration.exe"

; Request application privileges for Windows Vista and higher
RequestExecutionLevel admin

Function RelGotoPage
  IntCmp $R9 0 0 Move Move
    StrCmp $R9 "X" 0 Move
      StrCpy $R9 "120"
 
  Move:
  SendMessage $HWNDPARENT "0x408" "$R9" ""
FunctionEnd

SpaceTexts None

;All Variables
Var DisplayDPI

;--------------------------------

; Pages

; text for mui pages
!define MUI_UI "${__FILEDIR__}\ui.exe"
	
	; Header
	;!define MUI_HEADERIMAGE
	;!define MUI_WELCOMEFINISHPAGE_BITMAP_NOSTRETCH
	!define MUI_WELCOMEFINISHPAGE_BITMAP_STRETCH FitControl
	;!define MUI_WELCOMEFINISHPAGE_BITMAP "${__FILEDIR__}\banner.bmp"
	
	; Welcome page
	!define MUI_WELCOMEPAGE_TITLE "Radio Restoration for Grand Theft Auto IV Complete Edition"
	!define MUI_WELCOMEPAGE_TEXT "This installer provides an easy and automated way to restore the removed radio music in Grand Theft Auto IV Complete Edition.$\r$\n$\r$\nClick Next to continue with the installation."
	
	; License page
	!define MUI_PAGE_HEADER_TEXT "Information"
    !define MUI_PAGE_HEADER_SUBTEXT "Details about this modification."
	!define MUI_LICENSEPAGE_TEXT_TOP " "
	!define MUI_LICENSEPAGE_TEXT_BOTTOM " "
	!define MUI_LICENSEPAGE_BUTTON "Next"
	
	; Components page
	!define MUI_COMPONENTSPAGE_TEXT_TOP "Select the components you want to install:"
	; !define MUI_COMPONENTSPAGE_TEXT_COMPLIST ""
	!define MUI_COMPONENTSPAGE_TEXT_INSTTYPE " "
	!define MUI_COMPONENTSPAGE_TEXT_DESCRIPTION_TITLE "Component description"
	!define MUI_COMPONENTSPAGE_TEXT_DESCRIPTION_INFO "Hover your mouse over a component to see its description"
	
	; Directory page
	!define MUI_DIRECTORYPAGE_TEXT_TOP "Select your game folder (Note: Folder with GTAIV.exe should automatically detected be and inputted here, if not, input it manually)"
	!define MUI_DIRECTORYPAGE_TEXT_DESTINATION "Select the folder where GTAIV.exe is located"
	; Finish page
	!define MUI_FINISHPAGE_TITLE "Installation complete"
	!define MUI_FINISHPAGE_TEXT "You can now launch the game! Press close to exit the installer."

!define MUI_PAGE_CUSTOMFUNCTION_SHOW DPIbanner
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "${__FILEDIR__}\info.rtf"
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_LANGUAGE "English"

Function DPIbanner
	InitPluginsDir
	StrCpy $DisplayDPI 96
	System::Call USER32::GetDpiForSystem()i.r0
	${If} $0 U<= 0
    	System::Call USER32::GetDC(i0)i.r1
    	System::Call GDI32::GetDeviceCaps(ir1,i88)i.r0
    	System::Call USER32::ReleaseDC(i0,ir1)
	${EndIf}
	${If} $0 > 168
		StrCpy $DisplayDPI 192
	${ElseIf} $0 > 144
		StrCpy $DisplayDPI 168
	${ElseIf} $0 > 120
		StrCpy $DisplayDPI 144
	${ElseIf} $0 > 96
		StrCpy $DisplayDPI 120
	${EndIf}
	StrCpy $0 ""
	
    ${NSD_SetImage} $mui.WelcomePage.Image "$EXEDIR\Resources\Banners\banner$DisplayDPI.bmp" $mui.WelcomePage.Image.Bitmap
    ${NSD_SetImage} $mui.FinishPage.Image "$EXEDIR\Resources\Banners\banner$DisplayDPI.bmp" $mui.FinishPage.Image.Bitmap
FunctionEnd

;--------------------------------

; The stuff to install

ComponentText "Select components to install." "Description of components:" "FusionFix is required for this mod. Select it here to automatically download and install it if you haven't installed it already."

Section "-CreateTempFolder"
	CreateDirectory "$EXEDIR\Resources\.temp"
SectionEnd

Section "-ExeCheck"
	SetOutPath $INSTDIR
	InitPluginsDir
  ${GetFileVersion} "$INSTDIR\GTAIV.exe" $5
  
  ${If} $5 =~ "1.0.*.0" 
	MessageBox MB_RETRYCANCEL "Game version is incompatible, please use the latest version of the game, or select folder with latest version." IDRETRY retryfolder IDCANCEL installerfail_1
	DetailPrint "Game version is incompatible, please use the latest version of the game."
  ${EndIf}

  ${If} $5 == ""
	MessageBox MB_RETRYCANCEL "Game executable invalid or not found, please select a proper directory." IDRETRY retryfolder IDCANCEL installerfail_1
	DetailPrint "Game executable invalid or not found, please select a proper directory."
  ${EndIf}
  
  Goto ExeOK
  
  retryfolder:
  StrCpy $R9 -1
  Call RelGotoPage
  Abort
  
  installerfail_1:
  DetailPrint "Cancelling installation."
  Abort
  
  ExeOK:
SectionEnd

SectionGroup /e "Required" grp3

Section /o "FusionFix" ff
	
	SetOutPath $INSTDIR

	NScurl::http GET "http://github.com/ThirteenAG/GTAIV.EFLC.FusionFix/releases/latest/download/GTAIV.EFLC.FusionFix.zip" "$EXEDIR\Resources\.temp\FusionFix.zip" /CANCEL /RESUME /END
	
	nsExec::Exec '"$EXEDIR\Resources\External\7za.exe" x "$EXEDIR\Resources\.temp\FusionFix.zip" -y'

SectionEnd

SectionGroup /e "Radio Restoration" grp1
Section "-Base Files" radiorestorer
	SetOutPath $INSTDIR
   ;Archive hash check
   
   	DetailPrint "Checking hashes of archives..."
	FindFirst $6 $7 "$EXEDIR\Resources\Radio Restorer\*.dat"
	loop:
	StrCmp $7 "" done
	HashInfo::GetFileCRCHash "CRC-32" "$EXEDIR\Resources\Radio Restorer\$7"
	Pop $8
	ReadINIStr $9 "$EXEDIR\Resources\Radio Restorer\hashes.ini" "Archives" "$7"
	${If} $9 != $8
		MessageBox MB_OK "Hashes of DATs incorrect, please try to extract the archive again or redownload it! Press OK to close the installer." IDOK installerfail_1
	${EndIf}
	DetailPrint "Hash of $7 is $8 [CORRECT]"
	FindNext $6 $7
	Goto loop
	done:
	FindClose $0

  ${If} ${FileExists} "$INSTDIR\update\pc\audio\config\game.dat16"
  MessageBox MB_YESNO "Radio files detected in overload folder! It is likely an older version of the Radio Restoration mod was installed. If you want to remove old files, press yes. WARNING: This will also remove previously installed audio mods." IDYES true IDNO false
  true:
	RMDir /r "$INSTDIR\update\pc\audio\"
	RMDir /r "$INSTDIR\update\tlad\pc\audio\"
	RMDir /r "$INSTDIR\update\tbogt\pc\audio\"
	  FindFirst $6 $7 "$INSTDIR\update\common\text\*RR.gxt"
	  loopgxt1:
      StrCmp $7 "" donegxt1
      Delete "$INSTDIR\update\common\text\$7"
      FindNext $6 $7
      Goto loopgxt1
      donegxt1:
      FindClose $0
	DetailPrint "Old files successfully deleted!"
	Goto next
  false:
	DetailPrint "Keeping old files may cause issues in the future."
  ${EndIf}
  next:
  
  SetOutPath $INSTDIR
  nsExec::Exec '"$EXEDIR\Resources\External\7za.exe" x "$EXEDIR\Resources\Radio Restorer\data1.dat" -y'
  
  Goto downgradeend
  
  installerfail_1:
  DetailPrint "Cancelling installation."
  Goto downgradeend
  
  FindFirst $6 $7 "$INSTDIR\update\common\text\*RR.gxt"
  loopgxt:
  StrCmp $7 "" donegxt
  Delete "$INSTDIR\update\common\text\$7"
  FindNext $6 $7
  Goto loopgxt
  donegxt:
  FindClose $0
  
  Delete $INSTDIR\update\tbogt\pc\e2_radio.xml
  Delete $INSTDIR\update\tbogt\pc\e2_audio.xml
  Delete $INSTDIR\update\tlad\pc\e1_radio.xml
  Delete $INSTDIR\update\tlad\pc\e1_audio.xml
  DetailPrint "Radio Restorer nstallation failed. All files related to radio restorer have been deleted. This has also deleted any previous audio/radio mods you may have had..."
  
  downgradeend:
SectionEnd

Section "Pre-cut songs" g1o1
SectionIn RO
SectionEnd

Section /o "Post-cut songs" g1o2

SectionEnd

Section /o "Restored beta songs" g1o3
SectionEnd

Section "-Options"
	SetOutPath $INSTDIR

	${If} ${SectionIsSelected} ${g1o1}
	${AndIf} ${SectionIsSelected} ${g1o2}
	${AndIf} ${SectionIsSelected} ${g1o3}
		nsExec::Exec '"$EXEDIR\Resources\External\7za.exe" x "$EXEDIR\Resources\Radio Restorer\opALL.dat" -y'
	${EndIf}
	
	${If} ${SectionIsSelected} ${g1o1}
	${AndIf} ${SectionIsSelected} ${g1o2}
	${AndIfNot} ${SectionIsSelected} ${g1o3}
		nsExec::Exec '"$EXEDIR\Resources\External\7za.exe" x "$EXEDIR\Resources\Radio Restorer\opCLASSIC.dat" -y'
	${EndIf}
	
	${If} ${SectionIsSelected} ${g1o1}
	${AndIfNot} ${SectionIsSelected} ${g1o2}
	${AndIfNot} ${SectionIsSelected} ${g1o3}
		nsExec::Exec '"$EXEDIR\Resources\External\7za.exe" x "$EXEDIR\Resources\Radio Restorer\opVANILLA.dat" -y'
	${EndIf}
	
	${If} ${SectionIsSelected} ${g1o1}
	${AndIf} ${SectionIsSelected} ${g1o3}
	${AndIfNot} ${SectionIsSelected} ${g1o2}
		nsExec::Exec '"$EXEDIR\Resources\External\7za.exe" x "$EXEDIR\Resources\Radio Restorer\opVANILLABETA.dat" -y'
	${EndIf}
	
SectionEnd

Section /o "Split radios" g1o4
	SetOutPath $INSTDIR
	nsExec::Exec '"$EXEDIR\Resources\External\7za.exe" x "$EXEDIR\Resources\Radio Restorer\opSPLITbase.dat" -y'
	${If} ${SectionIsSelected} ${g1o3}
		nsExec::Exec '"$EXEDIR\Resources\External\7za.exe" x "$EXEDIR\Resources\Radio Restorer\opSPLITBETA.dat" -y'
	${Else}
		nsExec::Exec '"$EXEDIR\Resources\External\7za.exe" x "$EXEDIR\Resources\Radio Restorer\opSPLITVANILLA.dat" -y'
	${EndIf}
SectionEnd

SectionGroupEnd

SectionGroupEnd


Function .onInit

	StrCpy $1 ${g1o3}
	
	SetRegView 32
	ReadRegStr $INSTDIR HKLM "SOFTWARE\Rockstar Games\Grand Theft Auto IV" "InstallFolder"
FunctionEnd

Function .onSelChange

FunctionEnd

Section "-Delete temp files"
RMDir /r "$EXEDIR\Resources\.temp"
RMDir "$EXEDIR\Resources\.temp"
SectionEnd

LangString desc_g1o1 ${LANG_ENGLISH} "This option restores all songs cut in 2018. Keeps only pre-cut Vladivostok playlist."
LangString desc_g1o2 ${LANG_ENGLISH} "This option keeps post-cut Vladivostok songs alongside pre-cut one."
LangString desc_g1o3 ${LANG_ENGLISH} "This option restores 4 cut songs with working DJ lines"
LangString desc_g1o4 ${LANG_ENGLISH} "Removes IV songs in Episodes on shared radios and vice versa. Makes interiors and lap dance in EFLC play same songs/radios as vanilla EFLC. DOES NOT REMOVE IV EXCLUSIVE STATIONS IN EPISODES AND VICE VERSA"
LangString desc_ff ${LANG_ENGLISH} "FusionFix is a modification for the game that fixes multiple game bugs, adds a file overloader (required for this mod) and more."

!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
  !insertmacro MUI_DESCRIPTION_TEXT ${g1o1} $(desc_g1o1)
  !insertmacro MUI_DESCRIPTION_TEXT ${g1o2} $(desc_g1o2)
  !insertmacro MUI_DESCRIPTION_TEXT ${g1o3} $(desc_g1o3)
  !insertmacro MUI_DESCRIPTION_TEXT ${g1o4} $(desc_g1o4)
  !insertmacro MUI_DESCRIPTION_TEXT ${ff} $(desc_ff)
!insertmacro MUI_FUNCTION_DESCRIPTION_END