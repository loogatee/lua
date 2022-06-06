#!/usr/bin/lua

LINE_NUMBERS = false


match_strings = {
      "1.  ",
      "2.  ",
      "3.  ",
      "4.  ",
      "5.  ",
      "6.  ",
      "7.  "
}

--[[
match_strings = {
      "Code:",
      "Documentation:",
      "Build Environment:",
      "Other notes:"
} --]]


--[[
match_strings = {
      "  PwrCon Image L",
      "  Issues",
      "  New Messages",
      " ---"
}
--]]

--[[
match_strings = {
      "  Power Controller",
      "  SCM",
      "  IOM",
      " ---"
}
--]]


--[[
match_strings = {
    "void Rmi::",
    "Rmi::"
}
--]]


--[[
match_strings = {
    "TU08 Queue",
    "TU16 Queue",
    "void Queue",
    "void *memcpy"
}
--]]


require('string')

if arg[1] == nil then
    print("\nError: no filename entered")
    print("usage: jpr.lua filename")
    return
end



fd = io.open(arg[1], 'r')
if fd == nil then
    print('\nERROR: opening ' .. arg[1])
    return
end


i     = 0
SS    = ""
first = true

repeat

    Fdata = fd:read()                                                       -- reads 1 line only
    i = i + 1
    if Fdata ~= nil then
        for j=1,#match_strings do
            if string.find(Fdata,match_strings[j],1,true) ~= nil then
                if string.find(Fdata,";",1,true) == nil then                -- C code: avoid highlighting fwd refs
                    if first == true then
                        first = false
                        SS = string.format("%d",i)
                    else
                        SS = string.format("%s,%d",SS,i)
                    end
                end
            end
        end
    end

until Fdata == nil

fd:close()

if LINE_NUMBERS == true then
    s1 = "\\begin{Verbatim}[numbers=left,fontsize=\\small,highlightcolor=lightgray,highlightlines={" .. SS .. "}]\n"
else
    s1 = "\\begin{Verbatim}[fontsize=\\small,highlightcolor=lightgray,highlightlines={" .. SS .. "}]\n"
end


Header = [[
\documentclass{article}
\usepackage{geometry}
\usepackage{nopageno}
\usepackage{fvextra}
\usepackage{xcolor}
\geometry{
     a4paper,
     total={192mm,280mm},
     left=10mm,
     top=10mm,
}
\begin{document}
% tiny scriptsize footnotesize small normalsize large
]]


Footer = [[
\end{Verbatim}
\end{document}
]]


fd = io.open(arg[1], 'rb')
if fd == nil then
    print('\nERROR: opening ' .. arg[1])
    return
end

Fdata = fd:read("*all")
fd:close()

T={}
T[#T+1]=Header
T[#T+1]=s1
T[#T+1]=Fdata
T[#T+1]=Footer

S = table.concat(T)



fd = io.open("/home/john.reed/temp/tmptmp.tex", 'wb')
fd:write(S)
fd:close()


os.execute("/usr/bin/pdflatex -output-directory=/home/john.reed/temp /home/john.reed/temp/tmptmp.tex")


os.execute("/cygdrive/c/Program\\ Files\\ \\(x86\\)/Adobe/Acrobat\\ Reader\\ DC/Reader/AcroRd32.exe C:/cygwin64/home/john.reed/temp/tmptmp.pdf")


















