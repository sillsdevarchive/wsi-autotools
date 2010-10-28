;NSIS Modern User Interface
;@PRODUCT@ Font NSIS Installer script
;Written by Martin Hosken

; This line is included to pull in the MS system.dll plugin rather than the
; stubbed debian one. You should get the MS system.dll and put it in the templates/
; dir or comment out this line if building on windows
;@if $(sub MSWin32,,$(.OS)),!addplugindir $(.TEMPLATE_DIR)/../nsis@
  SetCompressor lzma
@osslash !addplugindir $(.TEMPLATE_DIR)/../nsis@

; Some useful definitions that may need changing for different font versions
!ifndef VERSION
  !define VERSION @VERSION@
!endif

!define FONTNAME "@or $(DESC_NAME),$(titlecase $(PRODUCT))@"
!define SRC_ARCHIVE "ttf-sil-@PRODUCT@-${VERSION}.zip"
@foreach f,$(FONTS),!define FONT_$(f)_FILE "$($(f)_TARGET)"@
;!define FONT_REG_FILE "${FONTNAME}.ttf"
;!define FONT_BOLD_FILE "${FONTNAME}-Bold.ttf"
!define INSTALL_SUFFIX "SIL\Fonts\@titlecase $(PRODUCT)@"
!define FONT_DIR "$WINDIR\Fonts"

;-----------------------------
; Macros for Font installation
;-----------------------------
!addincludedir @osslash $(.TEMPLATE_DIR)/../nsis@
!include FileFunc.nsh
!include FontRegAdv.nsh
!include WordFunc.nsh

!insertmacro VersionCompare
!insertmacro GetParent
!insertmacro un.GetFileName

!macro unFontName FONTFILE
  push ${FONTFILE}
  call un.GetFontName
!macroend

!macro FontName FONTFILE
  push ${FONTFILE}
  call GetFontName
!macroend

Function GetFontName
  Exch $R0
  Push $R1
  Push $R2

  System::Call *(i${NSIS_MAX_STRLEN})i.R1
  System::Alloc ${NSIS_MAX_STRLEN}
  Pop $R2
  System::Call gdi32::GetFontResourceInfoW(wR0,iR1,iR2,i1)i.R0
  IntCmp $R0 0 GFN_error
	System::Call *$R2(&w${NSIS_MAX_STRLEN}.R0)
	Goto GFN_errordone
  GFN_error:
	StrCpy $R0 error
  GFN_errordone:
  System::Free $R1
  System::Free $R2

  Pop $R2
  Pop $R1
  Exch $R0
FunctionEnd

Function un.GetFontName
  Exch $R0
  Push $R1
  Push $R2

  System::Call *(i${NSIS_MAX_STRLEN})i.R1
  System::Alloc ${NSIS_MAX_STRLEN}
  Pop $R2
  System::Call gdi32::GetFontResourceInfoW(wR0,iR1,iR2,i1)i.R0
  IntCmp $R0 0 GFN_error
	System::Call *$R2(&w${NSIS_MAX_STRLEN}.R0)
	Goto GFN_errordone
  GFN_error:
	StrCpy $R0 error
  GFN_errordone:
  System::Free $R1
  System::Free $R2

  Pop $R2
  Pop $R1
  Exch $R0
FunctionEnd

!macro unRemoveTTF FontFile
  Push $0
  Push $R0
  Push $R1
  Push $R2
  Push $R3
  Push $R4

  !define Index 'Line${__LINE__}'

; Get the Font's File name
  ${un.GetFileName} ${FontFile} $0
  !define FontFileName $0

;  DetailPrint "Testing that $FONT_DIR\${FontFileName} exists"
  IfFileExists "$FONT_DIR\${FontFileName}" ${Index} "${Index}-End"

${Index}:
  ClearErrors
  ReadRegStr $R0 HKLM "SOFTWARE\Microsoft\Windows NT\CurrentVersion" "CurrentVersion"
  IfErrors "${Index}-9x" "${Index}-NT"

"${Index}-NT:"
  StrCpy $R1 "Software\Microsoft\Windows NT\CurrentVersion\Fonts"
  goto "${Index}-GO"

"${Index}-9x:"
  StrCpy $R1 "Software\Microsoft\Windows\CurrentVersion\Fonts"
  goto "${Index}-GO"

  !ifdef FontBackup
  "${Index}-GO:"
  ;Implementation of Font Backup Store
	StrCpy $R2 ''
	ReadRegStr $R2 HKLM "${FontBackup}" "${FontFileName}"
	StrCmp $R2 'OK' 0 "${Index}-Skip"

	ClearErrors
	!insertmacro FontName "$FONT_DIR\${FontFileName}"
	pop $R2
	IfErrors 0 "${Index}-Remove"
	MessageBox MB_OK "$R2"
	goto "${Index}-End"

  "${Index}-Remove:"
	StrCpy $R2 "$R2 (TrueType)"
	System::Call "GDI32::RemoveFontResourceA(t) i ('${FontFileName}') .s"
	DeleteRegValue HKLM "$R1" "$R2"
	DeleteRegValue HKLM "${FontBackup}" "${FontFileName}"
	EnumRegValue $R4 HKLM "${FontBackup}" 0
	IfErrors 0 "${Index}-NoError"
	  MessageBox MB_OK "FONT (${FontFileName}) Removal.$\r$\n(Registry Key Error: $R4)$\r$\nRestart computer and try again. If problem persists contact your supplier."
	  Abort "EnumRegValue Error: ${FontFileName} triggered error in EnumRegValue for Key $R4."
  "${Index}-NoError:"
	StrCmp $R4 "" 0 "${Index}-NotEmpty"
	  DeleteRegKey HKLM "${FontBackup}" ; This will delete the key if there are no more fonts...
  "${Index}-NotEmpty:"
	Delete /REBOOTOK "$FONT_DIR\${FontFileName}"
	goto "${Index}-End"
  "${Index}-Skip:"
	goto "${Index}-End"
  !else
  "${Index}-GO:"

	ClearErrors
	!insertmacro unFontName "$FONT_DIR\${FontFileName}"
	pop $R2
;    DetailPrint "Uninstalling font name $R2"
	IfErrors 0 "${Index}-Remove"
	MessageBox MB_OK "$R2"
	goto "${Index}-End"

  "${Index}-Remove:"
	StrCpy $R2 "$R2 (TrueType)"
	System::Call "GDI32::RemoveFontResourceA(t) i ('${FontFileName}') .s"
	DeleteRegValue HKLM "$R1" "$R2"
	delete /REBOOTOK "$FONT_DIR\${FontFileName}"
	goto "${Index}-End"
  !endif

"${Index}-End:"

  !undef Index
  !undef FontFileName

  pop $R4
  pop $R3
  pop $R2
  pop $R1
  Pop $R0
  Pop $0
!macroend


;--------------------------------
;Include Modern UI

  !include "MUI.nsh"

;--------------------------------
;General

  ;Name and file
  Name "${FONTNAME} Font (${VERSION})"
  Caption "@DESC_SHORT@"

  OutFile "${FONTNAME}-${VERSION}.exe"
  ;OutFile "${FONT_REG_FILE}"
  ;OutFile "${FONT_BOLD_FILE}"
  InstallDir $PROGRAMFILES\${INSTALL_SUFFIX}

  ;Get installation folder from registry if available
  InstallDirRegKey HKLM "Software\${INSTALL_SUFFIX}" ""

;--------------------------------
;Interface Settings

  !define MUI_ABORTWARNING

;--------------------------------
;Pages

  !insertmacro MUI_PAGE_WELCOME
  @and $(LICENSE),!insertmacro MUI_PAGE_LICENSE "$(LICENSE)"@
  !insertmacro MUI_PAGE_COMPONENTS
  !insertmacro MUI_PAGE_DIRECTORY
  !insertmacro MUI_PAGE_INSTFILES
  !insertmacro MUI_PAGE_FINISH

  !insertmacro MUI_UNPAGE_CONFIRM
  !insertmacro MUI_UNPAGE_INSTFILES
  !define MUI_STARTMENUPAGE

  !define MUI_STARTMENUPAGE_REGISTRY_ROOT "HKLM"
  !define MUI_STARTMENUPAGE_REGISTRY_KEY \
	"Software\Microsoft\Windows\CurrentVersion\Uninstall\${FONTNAME}"
  !define MUI_STARTMENUPAGE_REGISTRY_VALUENAME "Start Menu Folder"
  !define MUI_STARTMENUPAGE_FONT_VARIABLE $R9
  !define MUI_STARTMENUPAGE_FONT_DEFAULTFOLDER "SIL\Fonts\@PRODUCT@"

;--------------------------------
;Languages

  !insertmacro MUI_LANGUAGE "English"

  VIAddVersionKey /LANG=${LANG_ENGLISH} "ProductName" "${FONTNAME}"
  VIAddVersionKey /LANG=${LANG_ENGLISH} "ProductVersion" "${VERSION}"
  VIAddVersionKey /LANG=${LANG_ENGLISH} "FileVersion" "${VERSION}"
  VIAddVersionKey /LANG=${LANG_ENGLISH} "CompanyName" "SIL International"
  VIAddVersionKey /LANG=${LANG_ENGLISH} "Comments" "@DESC_SHORT@"
  VIAddVersionKey /LANG=${LANG_ENGLISH} "FileDescription" "${FONTNAME} Font installer"
  @and $(COPYRIGHT),VIAddVersionKey /LANG=${LANG_ENGLISH} "LegalCopyright" "$(COPYRIGHT)"@
  VIProductVersion @WINDOWS_VERSION@

;--------------------------------
;Installer Sections

Section "!${FONTNAME} Font" SecFont

  SetOutPath "$WINDIR\Fonts"
  StrCpy $FONT_DIR $FONTS

  ReadRegStr $0 HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${FONTNAME}" "Version"
  IfErrors BranchTestRem
  ${VersionCompare} $0 ${VERSION} $R0
  IntCmp $R0 1 BranchQuery BranchQuery BranchUninstall

  BranchQuery:
	MessageBox MB_YESNO|MB_ICONQUESTION "A newer or same version of ${FONTNAME} is already installed. Do you want me to force the installation of this font package?" /SD IDNO IDYES BranchUninstall

  Abort "Installation of ${FONTNAME} aborting"

  BranchUninstall:
	; execute the uninstaller if it's there else abort
	ReadRegStr $0 HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${FONTNAME}" "UninstallString"
	${GetParent} "$0" $1
	ExecWait '"$0" /S _?=$1'

  BranchInstall:
	;ADD YOUR OWN FILES HERE...
	;File "${FONT_REG_FILE}"  ; done by InstallTTF
	;File "${FONT_BOLD_FILE}" ; done by InstallTTF

	@foreach f,$(FONTS),!insertmacro InstallTTF "${FONT_$(f)_FILE}"@

	SendMessage ${HWND_BROADCAST} ${WM_FONTCHANGE} 0 0 /TIMEOUT=5000

	SetOutPath "$INSTDIR"
	;Default installation folder

	;Store installation folder
	WriteRegStr HKLM "Software\${INSTALL_SUFFIX}" "" $INSTDIR

	;Create uninstaller
	WriteUninstaller "$INSTDIR\Uninstall.exe"

	; add keys for Add/Remove Programs entry
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${FONTNAME}" \
				 "DisplayName" "${FONTNAME} ${VERSION}"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${FONTNAME}" \
				 "UninstallString" "$INSTDIR\Uninstall.exe"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${FONTNAME}" \
				 "Version" "${VERSION}"
	Goto BranchDone

  BranchTestRem:
	@foreach f,$(FONTS),IfFileExists "$WINDIR/Fonts/${FONT_$(f)_FILE}" 0 BranchNoExist@
;    IfFileExists "$WINDIR\Fonts\${FONT_REG_FILE}" 0 BranchNoExist

	MessageBox MB_YESNO|MB_ICONQUESTION "Would you like to overwrite existing ${FONTNAME} fonts?" /SD IDYES IDYES BranchOverwrite ; skipped if file doesn't exist

	Abort

  BranchOverwrite:
	  @foreach f,$(FONTS),!insertmacro RemoveTTF "${FONT_$(f)_FILE}"@
	  SetOverwrite try
	  Goto BranchInstall
  BranchNoExist:
	  SetOverwrite ifnewer ; NOT AN INSTRUCTION, NOT COUNTED IN SKIPPINGS
	  Goto BranchInstall

  BranchDone:
SectionEnd

Section -StartMenu
  @and $(LICENSE),File "$(LICENSE)"@
  @foreach f,$(DOCS),File "/ONAME=$(sub /,\,$OUTDIR/$(f))" "$(osslash doc/$(f))"@
  !insertmacro MUI_STARTMENU_WRITE_BEGIN "FONT"
  SetShellVarContext all
  CreateDirectory $SMPROGRAMS\${MUI_STARTMENUPAGE_FONT_VARIABLE}
  IfFileExists $SMPROGRAMS\${MUI_STARTMENUPAGE_FONT_VARIABLE} createIcons
	SetShellVarContext current
	CreateDirectory $SMPROGRAMS\${MUI_STARTMENUPAGE_FONT_VARIABLE}

  createIcons:
	@foreach f,$(DOCS),$(sub /,\,CreateShortCut $SMPROGRAMS/${MUI_STARTMENUPAGE_FONT_VARIABLE}/$(f).lnk $OUTDIR/$(f))@
	CreateShortCut $SMPROGRAMS\${MUI_STARTMENUPAGE_FONT_VARIABLE}\Uninstall.lnk $INSTDIR\Uninstall.exe
	WriteRegStr ${MUI_STARTMENUPAGE_REGISTRY_ROOT} "${MUI_STARTMENUPAGE_REGISTRY_KEY}" "Menus" "$SMPROGRAMS\${MUI_STARTMENUPAGE_FONT_VARIABLE}"
  !insertmacro MUI_STARTMENU_WRITE_END
SectionEnd

;Optional source font - as a compressed archive
Section "Documentation" SecSrc

  SetOutPath "$INSTDIR"
  SetOverwrite ifnewer
  ;ADD YOUR OWN FILES HERE...
  @and $(EXTRA_DIST),$(foreach f,$(unique $(sub /.*?$,,$(EXTRA_DIST))),CreateDirectory $(sub /,\,"$OUTDIR/$(f)"))@
  @and $(EXTRA_DIST),$(foreach f,$(EXTRA_DIST),File "/ONAME=$(sub /,\,$OUTDIR/$(f))" "$(osslash $(f))")@

SectionEnd


;--------------------------------
;Descriptions

  ;Language strings
  LangString DESC_SecFont ${LANG_ENGLISH} "Install the ${FONTNAME} font (version ${VERSION}). @DESC_SHORT@"
;  LangString DESC_SecSrc ${LANG_ENGLISH} "Install the source font and Graphite code for ${FONTNAME} (version ${VERSION}). You only need this if you are a font developer."


  ;Assign language strings to sections
  !insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
	!insertmacro MUI_DESCRIPTION_TEXT ${SecFont} $(DESC_SecFont)
;    !insertmacro MUI_DESCRIPTION_TEXT ${SecSrc} $(DESC_SecSrc)
  !insertmacro MUI_FUNCTION_DESCRIPTION_END

;--------------------------------
;Uninstaller Section

Section "Uninstall"

  ;ADD YOUR OWN FILES HERE...

; uninstaller can only call unFunctions!!
;    !insertMacro RemoveFON "${FONT_REG_FILE}" "${FONTNAME} (TrueType)"
;    !insertMacro RemoveFON "${FONT_BOLD_FILE}" "${FONTNAME} Bold (TrueType)"
;    SendMessage ${HWND_BROADCAST} ${WM_FONTCHANGE} 0 0 /TIMEOUT=5000

	StrCpy $FONT_DIR $FONTS
;    DetailPrint "unRemoveTTF ${FONT_REG_FILE}"
	@foreach f,$(FONTS),!insertmacro unRemoveTTF "${FONT_$(f)_FILE}"@
;  Delete  /REBOOTOK "$WINDIR\Fonts\${FONT_REG_FILE}"
;  Delete  /REBOOTOK "$WINDIR\Fonts\${FONT_BOLD_FILE}"
  SendMessage ${HWND_BROADCAST} ${WM_FONTCHANGE} 0 0 /TIMEOUT=5000

;  !insertmacro MUI_STARTMENU_GETFOLDER FONT ${MUI_STARTMENU_FONT_VARIABLE}
  ReadRegStr $0 HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${FONTNAME}" "Menus"
  @and $(EXTRA_DIST),$(foreach f,$(EXTRA_DIST),Delete "$(sub /,\,$INSTDIR/$(f))")@
  @foreach f,$(DOCS),Delete "$(sub /,\,$INSTDIR/$(f))"@
  Delete "$INSTDIR\Uninstall.exe"
  @and $(EXTRA_DIST),$(foreach f,$(unique $(sub /.*?$,,$(EXTRA_DIST))),RMDir $(sub /,\,"$INSTDIR/$(f)"))@
  RMDir "$INSTDIR"
  @foreach f,$(DOCS),$(sub /,\,Delete "$0/$(f).lnk")@
  Delete "$0\Uninstall.lnk"
  RMDir "$0"


;  ReadRegStr $0 "${MUI_STARTMENUPAGE_REGISTRY_ROOT}" \
;    "${MUI_STARTMENUPAGE_REGISTRY_KEY}" "${MUI_STARTMENUPAGE_REGISTRY_VALUENAME}"

;  StrCmp $0 "" noshortcuts
;    foreach f,$(DOCS),$(sub /,\,Delete $0/$(f))
;    Delete $0\Uninstall.lnk
;    Delete $0\License.lnk
;    RMDir $0

  noshortcuts:

;  DeleteRegKey /ifempty HKLM "Software\${INSTALL_SUFFIX}"
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${FONTNAME}"

SectionEnd
