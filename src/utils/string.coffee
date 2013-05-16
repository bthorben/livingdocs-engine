# String Helpers
# --------------
# inspired by [https://github.com/epeli/underscore.string]()
@S = do ->

  # convert 'camelCase' to 'Camel Case'
  humanize: (str) ->
    uncamelized = $.trim(str).replace(/([a-z\d])([A-Z]+)/g, '$1 $2').toLowerCase()
    @titleize( uncamelized )

  capitalize : (str) ->
      str = if !str? then '' else String(str)
      return str.charAt(0).toUpperCase() + str.slice(1);

  # convert the first letter of every word to uppercase
  titleize: (str) ->
    if !str?
      ''
    else
      String(str).replace /(?:^|\s)\S/g, (c) ->
        c.toUpperCase()

  # camelize: (str) ->
  #   $.trim(str).replace(/[-_\s]+(.)?/g, (match, c) ->
  #     c.toUpperCase()

  # dasherize: (str) ->
  #   $.trim(str).replace(/([A-Z])/g, '-$1').replace(/[-_\s]+/g, '-').toLowerCase()

  # classify: (str) ->
  #   $.titleize(String(str).replace(/[\W_]/g, ' ')).replace(/\s/g, '')



