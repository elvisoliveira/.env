function clearOccurrences()
    scite.SendEditor(SCI_SETINDICATORCURRENT, 0)
    scite.SendEditor(SCI_INDICATORCLEARRANGE, 0, editor.Length)
end

function markOccurrences()
    if editor.SelectionStart == editor.SelectionEnd then
        return
    end
    clearOccurrences()
    scite.SendEditor(SCI_INDICSETSTYLE, 0, INDIC_ROUNDBOX)
    scite.SendEditor(SCI_INDICSETFORE, 0, 255)
    local txt = GetCurrentWord()
    local flags = SCFIND_WHOLEWORD
    local s,e = editor:findtext(txt,flags,0)
    while s do
        scite.SendEditor(SCI_INDICATORFILLRANGE, s, e - s)
        s,e = editor:findtext(txt,flags,e+1)
    end
end

function isWordChar(char)
    local strChar = string.char(char)
    local beginIndex = string.find(strChar, '%w')
    if beginIndex ~= nil then
        return true
    end
    if strChar == '_' or strChar == '$' then
        return true
    end
    return false
end

function GetCurrentWord()
    local beginPos = editor.CurrentPos
    local endPos = beginPos
    if editor.SelectionStart ~= editor.SelectionEnd then
        return editor:GetSelText()
    end
    while isWordChar(editor.CharAt[beginPos-1]) do
        beginPos = beginPos - 1
    end
    while isWordChar(editor.CharAt[endPos]) do
        endPos = endPos + 1
    end
    return editor:textrange(beginPos,endPos)
end
