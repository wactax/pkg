#!/usr/bin/env coffee

> path > join dirname basename
  json5
  fs > cpSync mkdirSync constants
  @w5/i18n
  @w5/i18n/i18n_bin.js
  @w5/walk > walkRel
  @w5/uridir
  @w5/write
  @w5/read
  @w5/yml/Yml

PWD = uridir import.meta
ROOT = dirname PWD
UI = join ROOT, 'ui'

await i18n(
  PWD
  md:(root, file, LANG_LI)=>
    rdir = root[PWD.length+1..]
    switch basename(rdir)
      when 'ui.i18n'
        for [lang] from LANG_LI
          fp = join(UI,'i18n',dirname(rdir),file.slice(0,-2)+lang)
          mkdirSync dirname(fp),recursive:true
          cpSync(
            root+lang+'/'+file
            fp
          )
      else
        pos = rdir.indexOf('api.i18n')
        if pos > 0
          for [lang] from LANG_LI
            md = read join root+lang+'/'+file
            md = md.replace(
              /<br\s+([^\/>]+)>/g
              (_,s)=>
                '${'+s+'}'
            )
            outfp = [
              PWD
              rdir[..pos-1]+'api'+rdir[pos+8..-2]
              'I18N'
              lang
              file[..-3]+'js'
            ].join('/')
            write(
              outfp
              'export default '+JSON.stringify md
            )
    #console.log 'pkg/i18n.coffee >>>', root+workdir+lang+'/'+file,  to
    return
  yml: (dir, default_lang)=>
    rdir = dir[PWD.length+1..]
    if basename(rdir) == 'ui.i18n'
      await I18nBin(
        dir
        join(dir[..-6], 'i18n')
        join(
          UI,'i18n',dirname(rdir)
        )
        default_lang
      )
    else
      pos = rdir.indexOf('api.i18n')
      if pos > 0
        o = {}
        for await i from walkRel(
          dir
          (i)=>
            i.startsWith('.') or not i.endsWith('.yml') or i.includes('/')
        )
          k = i[..-5]
          o[k]=Yml(dir)[k]

        outfp = [
          PWD
          rdir[...pos]+'api'+rdir[pos+8..]
          'I18N.js'
        ].join('/')
        console.log outfp
        write(
          outfp
          'export default '+json5.stringify o
        )

    return

)
process.exit()
