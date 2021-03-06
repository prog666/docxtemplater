#This class responsibility is to manage the scope
DocUtils=require('./docUtils')

module.exports=class ScopeManager
	###*
	 * [constructor description]
	 * @param  {[type]} @tags          [description]
	 * @param  {[type]} @scopePath     [description]
	 * @param  {[type]} @usedTags      [description]
	 * @param  {[type]} @scopeList     [description]
	 * @param  {[type]} @parser        [description]
	 * @param  {[type]} @moduleManager [description]
	 * @return {[type]}                [description]
	###
	constructor: (@tags, @scopePath, @usedTags, @scopeList, @parser, @moduleManager) -> 
		@moduleManager.scopeManager = this

	###*
	 * [loopOver description]
	 * @param  {[type]}   tag      [description]
	 * @param  {Function} callback [description]
	 * @param  {[type]}   inverted =             false [description]
	 * @return {[type]}            [description]
	###
	loopOver: (tag, callback, inverted = false) ->
		value = @getValue(tag)
		type = Object.prototype.toString.call(value)
		if inverted
			if !value? then return callback(@scopeList[@num])
			if !value then return callback(@scopeList[@num])
			if type=='[object Array]' && value.length == 0
				callback(@scopeList[@num])
			return

		if !value? then return
		if type == '[object Array]'
			for scope,i in value
				callback(scope)
		if type == '[object Object]'
			callback(value)
		if value == true
			callback(@scopeList[@num])

	###*
	 * [getValue description]
	 * @param  {[type]} tag  [description]
	 * @param  {[type]} @num =             @scopeList.length - 1 [description]
	 * @return {[type]}      [description]
	###
	getValue:(tag, @num = @scopeList.length - 1) ->
		scope = @scopeList[@num]
		parser = @parser(DocUtils.wordToUtf8(tag))
		result = parser.get(scope)
		if result == undefined and @num > 0 then return @getValue(tag, @num - 1)
		result

	###*
	 * [getValueFromScope description]
	 * @param  {[type]} tag [description]
	 * @return {[type]}     [description]
	###
	getValueFromScope: (tag) ->
		# search in the scopes (in reverse order) and keep the first defined value
		result = @getValue(tag)
		if result?
			if typeof result == 'string'
				@useTag(tag, true)
				value = result
				if value.indexOf(DocUtils.tags.start) != -1 or value.indexOf(DocUtils.tags.end) != -1
					throw new Error("You can't enter #{DocUtils.tags.start} or #{DocUtils.tags.end} inside the content of the variable. Tag: #{tag}, Value: #{result}")
			else if typeof result == "number"
				value = String(result)
			else value = result
		else
			@useTag(tag, false)
			value = "undefined"
		value

	###*
	 * set the tag as used, so that DocxGen can return the list of all tags
	 * @param  {[type]} tag [description]
	 * @param  {[type]} val [description]
	 * @return {[type]}     [description]
	###
	useTag: (tag, val) ->
		if val
			u = @usedTags.def
		else
			u = @usedTags.undef
		for s,i in @scopePath
			u[s] = {} unless u[s]?
			u = u[s]
		if tag != ""
			u[tag] = true
