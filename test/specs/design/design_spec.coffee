Design = require('../../../src/design/design')
CssModificatorProperty = require('../../../src/design/css_modificator_property')
Template = require('../../../src/template/template')
editableAttr = config.directives.editable.attr

describe 'Design', ->

  describe 'with no params', ->

    it 'adds a default namespace', ->
      test = -> new Design()
      expect(test).to.throw()


  describe 'with just a name', ->

    beforeEach ->
      @design = new Design(name: 'test')


    it 'has a name', ->
      expect(@design.name).to.equal('test')


    describe 'equals()', ->

      it 'recognizes the same design as equal', ->
        sameDesign = new Design(name: 'test')
        expect(@design.equals(sameDesign)).to.equal(true)


      it 'recognizes a different design', ->
        otherDesign = new Design(name: 'other')
        expect(@design.equals(otherDesign)).to.equal(false)


      it 'recognizes different versions', ->
        differentVersion = new Design(name: 'test', version: '1.0.0')
        expect(@design.equals(differentVersion)).to.equal(false)


  describe 'with a template and paragraph element', ->

    beforeEach ->
      @design = new Design(name: 'test')

      @design.add new Template
        id: 'title'
        html: """<h1 #{ editableAttr }="title"></h1>"""

      @design.add new Template
        id: 'text'
        html: """<p #{ editableAttr }="text"></p>"""


    it 'stores the template as Template', ->
      expect(@design.components[0]).to.be.an.instanceof(Template)


    describe 'get()', ->

      it 'gets the template by identifier', ->
        title = @design.get('test.title')
        expect(title).to.be.an.instanceof(Template)
        expect(title.identifier).to.equal('test.title')


      it 'gets the template by name', ->
        title = @design.get('title')
        expect(title).to.be.an.instanceof(Template)
        expect(title.identifier).to.equal('test.title')


      it 'returns undefined for a non-existing template', ->
        expect( @design.get('something-ludicrous') ).to.equal(undefined)


  describe 'groups', ->

    beforeEach ->
      @design = test.getDesign()


    it 'are available through #groups', ->
      groups = @design.groups
      expect(@design.groups[0]).to.have.property('name', 'Layout')


  describe 'styles configuration', ->

    beforeEach ->
      @design = new Design(test.designJson)


    it 'has global style Color', ->
      expect(@design.globalStyles['Color']).to.be.an.instanceof(CssModificatorProperty)


    it 'merges global, group and template styles', ->
      template = @design.get('hero')
      templateStyles = Object.keys template.styles
      expect(templateStyles).to.contain('Color') # global style
      expect(templateStyles).to.contain('Capitalized') # group style
      expect(templateStyles).to.contain('Extra Space') # template style


    it 'assigns global styles to a template with no other styles', ->
      template = @design.get('container')
      templateStyles = Object.keys template.styles
      expect(templateStyles).to.contain('Color') # global style
      expect(templateStyles).not.to.contain('Capitalized') # group style
      expect(templateStyles).not.to.contain('Extra Space') # template style


