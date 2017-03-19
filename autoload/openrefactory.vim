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
" openrefactory.vim
"
"   process methods to interface between the jar commands and the user
"
"   accessible methods:
"     openrefactory#Refactor()
"     openrefactory#QuickRefactor()
"     openrefactory#show_changes
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" TODO see if this can be eliminated...
let s:files= []

" TODO JAR add : to prompts instead of .
" gets all parameters necessary for said transformation
" RETURN: [ params... ]
function! s:InputParams(transformation)
  redraw!
  let params = or_commands#params(a:transformation)['params']
  let newParams = []

  for p in params
    call inputsave()
    let input = inputdialog(p["prompt"].': ', p['default'])
    call inputrestore()

    let newParams += [input]
  endfor

  return newParams
endfunction

" validates parameters for transformation against the jar
" RETURN: 1 if any invalid, else 0
function! s:ValidateParams(transformation, params)
  let results = or_commands#validate(a:transformation, a:params)['result']
  for r in results
    if r["valid"] ==? 'false'
      return 1
    endif
  endfor
  return 0 
endfunction


" TODO get the real offsets from jeff
" TODO helper method for qflist
" shows the log if there is one using quickfix
" RETURN: 1 if fatal errors, else 0
function! s:GetLog(log)
  let qflist = []
  let fatal = 0
  " parse log into qflist[] items, check for fatal errors
  for l in a:log
    let item = {
          \ 'filename': l["context"]["filename"] || "",
          \ 'lnum' : 1,
          \ 'text': l["message"],
          \ 'col' : l["context"]["offset"] || "",
          \ 'vcol' : 0,
          \}
    " get a buffer # for qflist
    let bnr = bufnr(fnameescape(filename))
    if bnr != -1
      let item['bufnr'] = bnr
    endif
    call add(qflist, item)

    "important
    if l["severity"] ==? "fatal"
      let fatal = 1
    endif
  endfor

  " show log in qflist
  call setqflist(qflist)
  cwindow
  echo "Review Error Log. :h OpenRefactory if you're lost"
  return fatal
endfunction

" Show change log in quickfix, using some hackery to show diffs
" TODO is this a horrible idea?
function! openrefactory#show_changes(...)
  let thefiles = []
  if a:0 > 0 
    let thefiles = a:1
  else
    let thefiles = s:files
  endif

  let qflist = []

  for f in thefiles
    let changes = f["filename"].".preview"
    let item = {
          \ 'filename' : changes,
          \ 'lnum' : 1
          \}
    let bnr = bufnr(fnameescape(changes))
    if bnr != -1
      let item['bufnr'] = bnr
    endif
    call add(qflist, item)
  endfor

  call setqflist(qflist)
  au BufRead *.preview call Diff()
  au BufRead *.preview set filetype=c
  cwindow
  echo "Review Changes"
endfunction

" find current preview file they're viewing, diff with original
function Diff()
  for f in s:files
    if expand("%p") == f["filename"].".preview"
      exec "edit ".f["filename"]
      exec "vertical diffs " . f["filename"].".preview"
    endif
  endfor
endfunction

" patch files and let s:files = something (safe guard fatal log)
function s:Patch(files)
  let s:files = a:files
  for f in s:files
    let changes = f["filename"].".preview"
    call system("patch -o ".changes." ".f["filename"]." ".f["patchFile"])
  endfor
endfunction

" clean up and / or patch changes
function! openrefactory#finish(...)
  au! BufRead *.preview call Diff()
  au! BufRead *.preview set filetype=c
  cclose
  if a:0 > 0
    let input = "y"
  else
    let input = inputdialog("Would you like to make these changes? (y/n) : ")
  endif
  if input ==? "y"
    " TODO refactor when you have a stroke of genius
    for f in s:files
      call system('mv ' . f["filename"].".preview ".f["filename"])
      call s:kill_preview_buffer(f)
    endfor
  elseif input ==? "n"
    for f in s:files
      call system("rm " . f["filename"].".preview")
      call s:kill_preview_buffer(f)
    endfor
  endif
  edit!
  "TODO restore cursor / file
  "execute 'goto ' . s:cursor
endfunction

" used to clean up buffers of *.preview after viewing changelog
function! s:kill_preview_buffer(file) 
  let bnr = bufnr(fnameescape(a:file["filename"].".preview"))
  if bnr != -1
    silent! exec "bd ".bnr
  endif
endfunction

" return 1 if log, else 0
function! s:RunTransformation(transformation, params)
  let response = or_commands#xrun(a:transformation, a:params)
  let log = response["log"]
  let files = response['files']
  let fatal = 0
  " if log, show. else, show changes
  if len(log) > 0
    if !(s:GetLog(log))
      call s:Patch(files)
    endif
    return 1
  else
    call s:Patch(files)
    return 0
  endif
endfunction

"work the magic
"TODO refactor
function! openrefactory#Refactor(transformation)
  let transformation = a:transformation
  if &mod
    echoe "Please save before refactoring"
    finish
  else 
    let s:files = []
    let params = s:InputParams(transformation)
    call s:ValidateParams(transformation, params)
    if !(s:RunTransformation(transformation, params))
      call openrefactory#show_changes()
    endif
  endif
endfunction

" get a quickie in 
function! openrefactory#QuickRename(new_name)
  if &mod
    echoe "Please save before renaming"
    finish
  else
    let s:files = []
    if !(s:RunTransformation("rename", [ a:new_name, 'false' ]))
      call openrefactory#finish("be quick about it")
    endif
  endif
endfunction

