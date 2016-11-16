Handlebars = require 'handlebars'
Printer = require 'handlebars'
Chai = require 'chai'
_ = require 'lodash'
flatmap = require 'flatmap'

expect = Chai.expect


snippet1 = '''
<b>
{{#if foo}}
<span>start</span>
{{bar}}
{{/if}}
</b>
'''


describe 'handlebars', ->

  it 'should produce an AST', ->
    ast = Handlebars.parse(snippet1)
    console.info JSON.stringify ast, null, 2
    expect(ast).to.have.property 'type', 'Program'
    expect(ast).to.have.property 'body'
    expect(ast.body).to.be.an.array
    expect(ast.body).to.have.length 3
    statement = ast.body[1]
    expect(statement).to.have.property 'type', 'BlockStatement'
    expect(statement).to.have.deep.property 'path.type', 'PathExpression'
    expect(statement).to.have.deep.property 'path.original', 'if'
    expect(statement).to.have.property 'params'
    expect(statement.params).to.be.an.array


  it 'should allow you to do a simple transformation', ->
    ast = Handlebars.parse(snippet1)
    transform = (node) ->
      switch
        when node.type is 'Program'
          _.merge({}, node, body: flatmap(node.body, transform))
        when node.type is 'BlockStatement'
          [
            {
              type: 'ContentStatement'
              value: "<span class='hb-block-#{node.path.original}' data-cond='#{node.params[0].original}'>"
            },
            _.merge({}, node, program: transform(node.program)),
            {
              type: 'ContentStatement'
              original: '</span>'
            }
          ]
        when node.type is 'MustacheStatement'
          [
            {
              type: 'ContentStatement'
              value: "<span class='hb-expr' data-expr='#{node.path.original}'>"
            }, _.clone(node), {
              type: 'ContentStatement'
              value: '</span>'
            }
          ]
        else _.clone(node)
    console.info Handlebars.compile(transform(ast))({foo: true})




