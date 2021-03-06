log = require('../modules/logging/log')
assert = require('../modules/logging/assert')
designConfigSchema = require('./design_config_schema')
CssModificatorProperty = require('./css_modificator_property')
Template = require('../template/template')
Design = require('./design')
Version = require('./version')
ImageRatio = require('./image_ratio')


module.exports = designParser =

  parse: (designConfig) ->
    @design = undefined
    if designConfigSchema.validate('design', designConfig)
      @createDesign(designConfig)
    else
      errors = designConfigSchema.getErrorMessages()
      throw new Error(errors)


  createDesign: (designConfig) ->
    { assets, components, componentProperties, groups, defaultComponents, imageRatios } = designConfig
    try
      @design = @parseDesignInfo(designConfig)
      @parseAssets(assets)
      @parseComponentProperties(componentProperties)
      @parseImageRatios(imageRatios)
      @parseComponents(components)
      @parseGroups(groups)
      @parseDefaults(defaultComponents)
    catch error
      error.message = "Error creating the design: #{ error.message }"
      throw error

    @design


  parseDesignInfo: (design) ->
    version = new Version(design.version)
    new Design
      name: design.name
      version: version.toString()


  parseAssets: (assets) ->
    return unless assets?
    @design.assets.addCss(assets.css)
    @design.assets.addJs(assets.js)


  # Note: Currently componentProperties consist only of design styles
  parseComponentProperties: (componentProperties) ->
    @componentProperties = {}
    for name, config of componentProperties
      config.name = name
      @componentProperties[name] = @createComponentProperty(config)


  parseImageRatios: (ratios) ->
    for name, ratio of ratios
      @design.imageRatios[name] = new ImageRatio
        name: name
        label: ratio.label
        ratio: ratio.ratio


  parseComponents: (components=[]) ->
    for { name, label, html, properties, directives } in components
      properties = @lookupComponentProperties(properties)

      component = new Template
        name: name
        label: label
        html: html
        properties: properties

      @parseDirectives(component, directives)
      @design.add(component)


  parseDirectives: (component, directives) ->
    for name, conf of directives
      directive = component.directives.get(name)
      assert directive, "Could not find directive #{ name } in #{ component.name } component."
      directiveConfig =
        imageRatios: @lookupImageRatios(conf.imageRatios)
      directive.setConfig(directiveConfig)


  lookupComponentProperties: (propertyNames) ->
    properties = {}
    for name in propertyNames || []
      property = @componentProperties[name]
      assert property, "The componentProperty '#{ name }' was not found."
      properties[name] = property

    properties


  lookupImageRatios: (ratioNames) ->
    return unless ratioNames?
    @mapArray ratioNames, (name) =>
      ratio = @design.imageRatios[name]
      assert ratio, "The imageRatio '#{ name }' was not found."
      ratio


  parseGroups: (groups=[]) ->
    for group in groups
      components = for componentName in group.components
        @design.get(componentName)

      @design.groups.push
        label: group.label
        components: components


  parseDefaults: (defaultComponents) ->
    return unless defaultComponents?
    { paragraph, image } = defaultComponents
    @design.defaultParagraph = @getComponent(paragraph) if paragraph
    @design.defaultImage = @getComponent(image) if image


  getComponent: (name) ->
    component = @design.get(name)
    assert component, "Could not find component #{ name }"
    component


  createComponentProperty: (styleDefinition) ->
    new CssModificatorProperty(styleDefinition)


  mapArray: (entries, lookup) ->
    newArray = []
    for entry in entries
      val = lookup(entry)
      newArray.push(val) if val?

    newArray


Design.parser = designParser
