Private = require("../../src/core/private")

xdescribe "private object", ->

  beforeEach ->
    @p = new Private()

  it "shall not allow reading unknown values", ->
    expect(->@p.attr("name")).toThrow()

  it "shall not allow writing unknown values", ->
    expect(->@p.attr("name", 55)).toThrow()

  describe "with 'name' attribute defined", ->

    beforeEach ->
      @p.define "name", "test"

    it "shall allow reading values with 'attr'", ->
      expect(@p.attr("name")).toEqual("test")

    it "shall allow changing values using 'attr' method", ->
      @p.attr("name", "bob")
      expect(@p.attr("name")).toEqual("bob")

    it "shall allow changing values using 'attr' method using fluid syntax", ->
      @p.attr("name", "bob").attr("name", "ann")
      expect(@p.attr("name")).toEqual("ann")

    it "shall not allow changing values directly", ->
      @p.name = "joe"
      expect(@p.attr("name")).toEqual("test")

    it "shall get json using 'toJSON' method", ->
      json = @p.toJSON()
      expect(json.name).toEqual("test")

    it "shall not be changed by direct change in json", ->
      json = @p.toJSON()
      json.name = "bob"
      expect(json.name).toEqual("bob")
      expect(@p.attr("name")).toEqual("test")

    it "shall be changed by 'attr' method called in json", ->
      json = @p.toJSON()
      json.attr("name", "bob")
      expect(json.name).toEqual("bob")
      expect(@p.attr("name")).toEqual("bob")


describe "subclass of private object", ->

  class Subclass extends Private
    constructor: ->
      super(["predefined"])

  s = null
  beforeEach ->
    s = new Subclass()

  it "shall have predefined property", ->
    s.attr("predefined")
