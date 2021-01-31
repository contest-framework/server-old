# Tertestrial plugin for Vim

## Installation

This is a normal Vim plugin. Install it like you install all your other plugins.

##### Vundle users

- add `Bundle 'kevgo/tertestrial-vim'` to your .vimrc file
- restart Vim and run `:BundleInstall`

##### Pathogen users

- clone to the bundle folder:

```
cd ~/.vim/bundle
git clone git://github.com/kevgo/tertestrial-vim.git
```

- restart Vim

## Activation in Vim

To assign keyboard shortcuts to the different test commands, put something like
this in your `.vimrc` file:

```viml
nnoremap <leader>e :call TertestrialAll()<cr>
nnoremap <leader>f :call TertestrialFile()<cr>
nnoremap <leader>l :call TertestrialLine()<cr>
nnoremap <leader>o :call TertestialRepeat()<cr>
nnoremap <leader>a :call TertestrialToggle()<cr>
nnoremap <leader>1 :call TertestrialSet(1)<cr>
nnoremap <leader>2 :call TertestrialSet(2)<cr>
nnoremap <leader>3 :call TertestrialSet(3)<cr>
nnoremap <leader>4 :call TertestrialSet(4)<cr>
autocmd BufWritePost * :call TertestrialFileSaved()
```

With these settings, you get the hotkeys:

- **leader-e:** run the complete test suite
- **leader-f:** run the current test file
- **leader-l:** run only the test at the current cursor position
- **leader-o:** re-run the last test
- **leader-a:** activate/deactivate auto-running the last run test on saving
  (see below)
- **leader-1:** activate mapping 1
- **leader-2:** activate mapping 2
- **leader-3:** activate mapping 3
- **leader-4:** activate mapping 4
- **[cmd-s]** or `:w[<enter>]` saves the current buffer and re-runs the last
  test
