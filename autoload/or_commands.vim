" or_commands.vim
"
"   Contains all of the methods from the OpenRefactory Protocol.
"   Each method will get a reply from the jar file and return if valid.
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
" Copyright (c) 2013 Auburn University and others.
" All rights reserved. This program and the accompanying materials
" are made available under the terms of the Eclipse Public License v1.0
" which accompanies this distribution, and is available at
" http://www.eclipse.org/legal/epl-v10.html
"
" Contributors:
"    Reed Allman (Auburn) - Initial API and implementation
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


let s:script_folder_path = escape( expand( '<sfile>:p:h:h' ), '\' )

" executes jar/ordemo.jar with given command on shell
" returns { response }
function! s:SendCommand(string)
  let command = 'java -cp ' . s:script_folder_path . '/jar/ordemo.jar org.openrefactory.internal.daemon.ORProxy '
  let command = command . shellescape( "[" . s:SetDir() . "," . a:string . "]" )
  let response = system(command)
  return response
endfunction

" if valid,
" returns:
"   { response }
function! s:GetValidResponse(command)
  let reply = s:SendCommand(a:command)
  let response = json_parser#parse(reply)

  if response["reply"] == "OK"
    return response
  else
    throw response["message"]
  endif
endfunction

" returns:
" selection
"   filename...
"     filename
"     offset
"     length
function! s:GetTextSelection()

  if mode() ==? 'v'
    " TODO fix this not working?
    let cursor = line2byte(line("'<")) + (col("'<") - 2)
    echo cursor
    let endsel = line2byte(line("'>")) + (col("'>") - 2)
    echo endsel
    let length = endsel - cursor
  else
    let cursor = line2byte(line(".")) + (col(".") - 2)
    let length = 0
  endif

  return { 'filename': expand('%:p'),
        \ 'offset': cursor,
        \ 'length': length, }
endfunction

function! s:SetDir()
  return s:MakeCommand("setdir", {
        \   "directory": expand('%:p:h'),
        \   "mode": "local" })
endfunction

function! s:MakeCommand(name, ...)
  if a:0 > 0
    let params = a:1
  else
    let params = { }
  endif

  let params['command'] = a:name
  return json_parser#stringify(params)
endfunction

function! or_commands#open()
  let command = s:MakeCommand('open', { 'version': 1.0 })
  return s:GetValidResponse(command)
endfunction

function! or_commands#close()
  let command = s:MakeCommand('close')
  call s:SendCommand(command)
endfunction

function! or_commands#about()
  let command = s:MakeCommand('about')
  return s:GetValidResponse(command)
endfunction

function! or_commands#setdir()
  let command = s:MakeCommand('setdir', {
        \   'directory': expand('%:p:h'),
        \   'mode': 'local' })
  return s:GetValidResponse(command)
endfunction

" returns:
"   transformation...
"     shortname
"     name
function! or_commands#list()
  let command = s:MakeCommand("list", {
        \ 'quality': "in_testing",
        \ 'textselection': s:GetTextSelection() })
  return s:GetValidResponse(command)
endfunction

" returns:
"   params...
"     label
"     prompt
"     type
"     default
function! or_commands#params(transformation)
  let command = s:MakeCommand("params", {
        \   "transformation":  a:transformation,
        \   "textselection" :  s:GetTextSelection() })
  return s:GetValidResponse(command)
endfunction

"returns:
"   [{message: "", valid: "boolean"} ... ]
function! or_commands#validate(transformation, arguments)
  let command = s:MakeCommand("validate", {
        \   "transformation": a:transformation,
        \   "textselection" : s:GetTextSelection(),
        \   "arguments"     : a:arguments })
  return s:GetValidResponse(command)
endfunction

"returns:
"   { transformation: ""
"     filelist: { }
"     log: { } 
function! or_commands#xrun(transformation, arguments)
  let command = s:MakeCommand("xrun", {
        \   "transformation": a:transformation,
        \   "textselection" : s:GetTextSelection(),
        \   "arguments"     : a:arguments })
  return s:GetValidResponse(command)
endfunction

function! or_commands#xgetfile(file)
  let command = s:MakeCommand("xgetfile", { "filename": a:file })
  return s:GetValidResponse(command)
endfunction

function! or_commands#xgetpatch(file)
  let command = s:MakeCommand("xgetpatch", { "filename": a:file  })
  return s:GetValidResponse(command)
endfunction

function! or_commands#xgetpatchfile(file)
  let command = s:MakeCommand("xgetpatchfile", { "filename": a:file })
  return s:GetValidResponse(command)
endfunction

function! or_commands#xstatus()
  let command = s:MakeCommand("xstatus")
  return s:GetValidResponse(command)
endfunction

function! or_commands#xabort()
  let command = s:MakeCommand("xabort")
  return s:GetValidResponse(command)
endfunction

