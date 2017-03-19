" openrefactory.vim plugin
"
" Mappings, commands
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

if exists("g:loaded_openrefactory")
  finish
endif
let g:loaded_openrefactory=1

" set up custom mappings... or not

"if !exists('g:openrefactory_refactor')
  "let g:openrefactory_refactor = '<Leader>g'
"endif

"if !exists('g:openrefactory_quickrename')
  "let g:openrefactory_quickrename = '<Leader>h'
"endif

"exec 'noremap <silent> ' . g:openrefactory_refactor . ' :CRefactor<CR>'
"exec 'noremap <silent> ' . g:openrefactory_quickrename . ' :CQuickRename<CR>'

function! s:list_transformations(a, l, p)
  let transformations = or_commands#list()['transformations']
  let display = ""
  for t in transformations
    let display = display . "\n" . t["shortName"]
  endfor
  return display
endfunction

command! -nargs=1 -complete=custom,<sid>list_transformations CRefactor  cal openrefactory#Refactor(<f-args>)
command! -nargs=1 CQuickRename cal openrefactory#QuickRename(<f-args>)
command! -bar CRefactorViewChanges cal openrefactory#show_changes()
command! -bar CRefactorFinish cal openrefactory#finish()

