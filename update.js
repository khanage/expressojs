var expressoParser = require('Expresso.Parser');
var Prelude = require('Prelude');
var Data = require('Expresso.Parser.Data');

function Expression(value) {

    this.toString = function() { return Data.expressionShow.show(value); };
}

function Expresso() {
    this.parseExpression = function(incoming) {
        var parse = expressoParser.parseExpressoExpression(incoming);

        return new Expression(parse.value0);
    };
};

global.Expresso = new Expresso();
