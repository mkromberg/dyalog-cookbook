﻿:Namespace UI
⍝ Dyalog Cookbook. Version 07
⍝ User interface
⍝ Vern: sjt30sep16

   ⍝ aliases
    (A E F M R U)←#.(APLTreeUtils Environment FilesAndDirs MyApp RefNamespace Utilities)

    ∇ Run;ui
      ui←R.Create'User Interface'
      ui←CreateGui ui
      ui←Init ui
      ui.∆Path←F.PWD
      DQ ui.∆form
      Shutdown
     ⍝ done
    ∇

    ∇ ui←CreateGui ui
      ui.∆LanguageCommands←''
      ui.∆MenuCommands←''
     
      ui←CreateForm ui
      ui←CreateMenubar ui
      ui←CreateEdit ui
      ui←CreateStatusbar ui
    ∇

    ∇ ui←CreateForm ui;∆
      ui.Font←⎕NEW'Font'(('Pname' 'APL385 Unicode')('Size' 16))
      ui.Icon←⎕NEW'Icon'(E.IconComponents{↓⍉↑⍵(⍺⍎¨⍵)}'Bits' 'CMap' 'Mask')
     
      ∆←''
      ∆,←⊂'Coord' 'Pixel'
      ∆,←⊂'Posn'(50 70)
      ∆,←⊂'Size'(400 500)
      ∆,←⊂'Caption' 'Frequency Counter'
      ∆,←⊂'MaxButton' 0
      ∆,←⊂'FontObj'ui.Font
      ∆,←⊂'IconObj'ui.Icon
      ui.∆form←⎕NEW'Form'∆
      ui.∆form.ui←ui
    ∇

    ∇ ui←CreateMenubar ui
      ui.MB←ui.∆form.⎕NEW⊂'Menubar'
     
      ui←CreateFileMenu ui
      ui←CreateLanguageMenu ui
     
      ui.∆MenuCommands.onSelect←⊂'OnMenuCommand'
      ui.∆MenuCommands.ui←ui
    ∇

    ∇ ui←CreateFileMenu ui
      ui.MenuFile←ui.MB.⎕NEW'Menu'(⊂'Caption' '&File')
     
      ui.Quit←ui.MenuFile.⎕NEW'MenuItem'(⊂'Caption'('Quit',(⎕UCS 9),'Alt+F4'))
      ui.∆MenuCommands,←ui.Quit
    ∇

    ∇ ui←CreateLanguageMenu ui;alph;mi
      ui.MenuLanguage←ui.MB.⎕NEW'Menu'(⊂'Caption' '&Language')
     
      :For alph :In U.m2n M.ALPHABETS.⎕NL 2
          mi←ui.MenuLanguage.⎕NEW'MenuItem'(⊂'Caption'alph)
          alph ui.{⍎⍺,'←⍵'}mi ⍝ Watch Out for conflict with control names
          ui.∆LanguageCommands,←mi
      :EndFor
      ui.∆LanguageCommands.Checked←ui.∆LanguageCommands∊ui⍎M.PARAMETERS.alphabet
      ui.∆MenuCommands,←ui.∆LanguageCommands
    ∇

    ∇ ui←CreateEdit ui;∆
      ∆←''
      ∆,←⊂'AcceptFiles' 1
      ∆,←⊂'Posn'(0 0)
      ∆,←⊂'Size'ui.∆form.Size
      ∆,←⊂'Style' 'Multi'
     
      ui.Edit←ui.∆form.⎕NEW'Edit'∆
      ui.Edit.onDropFiles←'OnDropFiles'
    ∇

    ∇ ui←CreateStatusbar ui;∆
      ui.SB←ui.∆form.⎕NEW'Statusbar'(⊂'Attach'('Bottom' 'Left' 'Bottom' 'Right'))
     
      ∆←''
      ∆,←⊂'Caption' 'Drag and drop onto this form files you want to review'
      ∆,←⊂'Coord' 'Prop'
      ∆,←⊂'Size'(⍬ 99)
      ui.Info←ui.SB.⎕NEW'StatusField'∆
      ui.SB.Posn[1]←ui.∆form.Size[1]-ui.SB.Size[1]+1
    ∇

    ∇ ui←Init ui
    ∇

    ∇ Z←OnDropFiles(obj xxx paths xxx xxx);job;ui;i;tbl
      ui←GetRef2ui obj
      tbl←0 2⍴' ' 0
      i←1
      :Repeat
          job←M.TxtToCsv i⊃paths
          tbl⍪←job.table
      :Until (job.status≢'OK')∨(≢paths)<i←i+1
     
      :If job.status≡'OK'
          ui.Edit.Text←{⍺,',',⍕⍵}/⊃{⍺(+/⍵)}⌸/↓[1]tbl
          ui.Info.Caption←IdentifySource paths
      :Else
          ui.Edit.Text←job.status
      :EndIf
      Z←0
    ∇

      IdentifySource←{
          1=≢⍵:⊃⍵                
          p←⎕NPARTS¨⍵
          {∧/⍵∊⊂⊃⍵}⊃¨p:⍕(⊂1 1 ⊃p),,/↑1↓¨p
          ⍕⍵
      }

    ∇ Z←OnMenuCommand(obj xxx);ui
      ui←GetRef2ui obj
      :Select obj
      :Case ui.Quit
          Z←0⊣⎕NQ ui.∆form'Close'
      :CaseList ui.∆LanguageCommands
          M.PARAMETERS.alphabet←obj.Caption
          ui.∆LanguageCommands.Checked←ui.∆LanguageCommands=obj
      :EndSelect
    ∇

    ∇ {r}←DQ ref
      r←⎕DQ ref
     ⍝ done
    ∇

    ∇ Shutdown
    ∇

    GetRef2ui←{9=⍵.⎕NC'ui':⍵.ui ⋄ ∇ ⍵.##}

:EndNamespace
