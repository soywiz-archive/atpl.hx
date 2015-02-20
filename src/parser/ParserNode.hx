///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

//export class NodeBuilder {
//	binary(left: ParserNodeExpression, op: string, right: ParserNodeExpression): ParserNodeExpression {
//		if (op == '=') {
//			return new ParserNodeAssignment(left, right);
//		} else {
//			return new ParserNodeBinaryOperation(left, op, right);
//		}
//	}
//}

import haxe.Json;

class ParserNode {
	public var type: String = '-';

	public function generateCode(context: ParserNodeGenerateCodeContext):string {
		return '<invalid>';
	}

    public function iterate(handler: ParserNode -> Void) {
		handler(this);
	}
}

interface ParserNodeGenerateCodeContext {
    public var doWrite: Bool;
}

class ParserNodeExpression extends ParserNode {
}

class ParserNodeWriteExpression extends ParserNodeExpression {
    public var expression: ParserNodeExpression;

	public function new(expression: ParserNodeExpression) {
		super();
	}

	public function generateCode(context: ParserNodeGenerateCodeContext):String {
		if (!context.doWrite) {
			throw 'A template that extends another one cannot have a body';
			return '';
		}
		return 'runtimeContext.writeExpression(' + this.expression.generateCode(context) + ')';
	}

	public function iterate(handler: ParserNode -> Void) {
		handler(this);
		this.expression.iterate(handler);
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

class ParserNodeContainer extends ParserNode {
	public var type: string = 'ParserNodeContainer';
    public var nodes: Array<ParserNode>;

	public function new(?nodes: Array<ParserNode>) {
		super();
        this.nodes = (nodes != null) ? nodes : [];
	}

	public function add(node: ParserNode) {
		this.nodes.push(node);
	}

	override public function generateCode(context: ParserNodeGenerateCodeContext):String {
		var output:string = '';
		for (n in this.nodes) output += this.nodes[n].generateCode(context);
		return output;
	}

	public function iterate(handler: ParserNode -> Void) {
		handler(this);
		for (n in this.nodes) this.nodes[n].iterate(handler);
	}
}

class ParserNodeContainerExpression extends ParserNodeExpression {
	public var type = 'ParserNodeContainerExpression';
    public var nodes: Array<ParserNode>;

	public function new(nodes: Array<ParserNode>) {
		super();
        this.nodes = (nodes != null) ? nodes : [];
	}

	public function add(node: ParserNode) {
		this.nodes.push(node);
	}

	public function generateCode(context: ParserNodeGenerateCodeContext):String {
		var output:string = '';
		for (n in this.nodes) output += this.nodes[n].generateCode(context);
		return output;
	}

	public function iterate(handler: ParserNode -> Void) {
		handler(this);
		for (n in this.nodes) this.nodes[n].iterate(handler);
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

class ParserNodeObjectItem extends ParserNode {
	public var type:String = 'ParserNodeObjectItem';
    private var key: ParserNodeExpression;
    private var value: ParserNodeExpression;

	public function new(key: ParserNodeExpression, value: ParserNodeExpression) {
		super();
        this.key = key;
        this.value = value;
	}

	public function generateCode(context: ParserNodeGenerateCodeContext) {
		return this.key.generateCode(context) + ' : ' + this.value.generateCode(context);
	}

    public function iterate(handler: ParserNode -> Void) {
		handler(this);
		this.key.iterate(handler);
		this.value.iterate(handler);
	}

}

class ParserNodeObjectContainer extends ParserNodeExpression {
	public var type:String = 'ParserNodeObjectContainer';
    private var items: Array<ParserNodeObjectItem>;

	public function new(items: Array<ParserNodeObjectItem>) {
		super();
        this.items = items;
	}

	public function generateCode(context: ParserNodeGenerateCodeContext) {
		return '{' + this.items.map(node => node.generateCode(context)).join(', ') + '}';
	}

	public function iterate(handler: ParserNode -> Void) {
		handler(this);
		for (n in this.items) this.items[n].iterate(handler);
	}
}

class ParserNodeArrayContainer extends ParserNodeExpression {
	public var type = 'ParserNodeArrayContainer';
    private var items: Array<ParserNodeExpression>;

	public function new(items: Array<ParserNodeExpression>) {
		super();
        this.items = items;
	}

	public function generateCode(context: ParserNodeGenerateCodeContext) {
		return '[' + this.items.map(node => node.generateCode(context)).join(', ') + ']';
	}

    public function iterate(handler: ParserNode -> Void) {
		handler(this);
		for (n in this.items) this.items[n].iterate(handler);
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

interface ParseNodeLiteralIdentifier {
	//type: string;
	//value: any;
	//generateCode(context: ParserNodeGenerateCodeContext);
}

class ParserNodeLiteral extends ParserNodeExpression implements ParseNodeLiteralIdentifier {
	public var type = 'ParserNodeLiteral';
    public var value: Dynamic;

	public function new(value: Dynamic) {
		super();
        this.value = value;
	}

	override public function generateCode(context: ParserNodeGenerateCodeContext) {
		return Json.stringify(this.value);
	}

    override public function iterate(handler: ParserNode -> Void) {
		handler(this);
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

class ParserNodeLeftValue extends ParserNodeExpression {
	public var type = 'ParserNodeLeftValue';

	public function generateAssign(context: ParserNodeGenerateCodeContext, expr: ParserNodeExpression):String {
		throw "Must implement";
	}
}

class ParserNodeIdentifier extends ParserNodeLeftValue implements ParseNodeLiteralIdentifier {
	public var type = 'ParserNodeIdentifier';
    public var value: String;

	public function new(value: string) {
		super();
        this.value = value;
	}

	override public function generateAssign(context: ParserNodeGenerateCodeContext, expr: ParserNodeExpression) {
		return 'runtimeContext.scopeSet(' + Json.stringify(this.value) + ', ' + expr.generateCode(context) + ')';
	}

    override public function generateCode(context: ParserNodeGenerateCodeContext) {
		return 'runtimeContext.scopeGet(' + Json.stringify(this.value) + ')';
	}
}

class ParserNodeStatement extends ParserNode {
    public var type = 'ParserNodeStatement';
}

class ParserNodeRaw extends ParserNodeExpression {
	public var type = 'ParserNodeRaw';
    public var value: String;
    public var putAlways = true;

	public function new(value: String, putAlways: Bool = true) {
		super();
        this.value = value;
        this.putAlways = putAlways;
	}

	override public function generateCode(context: ParserNodeGenerateCodeContext) {
		if (!context.doWrite && !this.putAlways) return '';
		return this.value;
	}
}

class ParserNodeStatementExpression extends ParserNodeStatement {
	public var type = 'ParserNodeStatementExpression';
    public var expression: ParserNodeExpression;

	public function new(expression: ParserNodeExpression) {
		super();
        this.expression = expression;
	}

	override public function generateCode(context: ParserNodeGenerateCodeContext) {
		return this.expression.generateCode(context) + ';';
	}

    override public function iterate(handler: ParserNode -> Void) {
		handler(this);
		this.expression.iterate(handler);
	}
}

class ParserNodeAssignment extends ParserNodeExpression {
	public var type = 'ParserNodeAssignment';
    public var leftValue: ParserNodeLeftValue;
    public var rightValue: ParserNodeExpression;

	public function new(leftValue: ParserNodeLeftValue, rightValue: ParserNodeExpression) {
		super();
        this.leftValue = leftValue;
        this.rightValue = rightValue;
	}

	public function generateCode(context: ParserNodeGenerateCodeContext) {
		return this.leftValue.generateAssign(context, this.rightValue);
	}

    public function iterate(handler: ParserNode -> Void) {
		handler(this);
		this.leftValue.iterate(handler);
		this.rightValue.iterate(handler);
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

class ParserNodeCommaExpression extends ParserNode {
	public var type = 'ParserNodeCommaExpression';
    public var expressions: Array<ParserNodeExpression>;
    public var names: Array<String> = null;

	public function new(expressions: Array<ParserNodeExpression>, names: Array<String> = null) {
		super();
        this.expressions = expressions;
        this.names = names;
	}

	override public function generateCode(context: ParserNodeGenerateCodeContext) {
		return this.expressions.map((item) => item.generateCode(context)).join(', ');
	}

	override public function iterate(handler: ParserNode -> Void) {
		handler(this);
		for (n in this.expressions) this.expressions[n].iterate(handler);
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

class ParserNodeArrayAccess extends ParserNodeExpression {
	public var type = 'ParserNodeArrayAccess';
    public var object: ParserNodeExpression;
    public var key: ParserNodeExpression;

	public function new(object: ParserNodeExpression, key: ParserNodeExpression) {
		super();
        this.object = object;
        this.key = key;
	}

	override public function generateCode(context: ParserNodeGenerateCodeContext) {
		return 'runtimeContext.access(' + this.object.generateCode(context) + ', ' + this.key.generateCode(context) + ')';
	}

    override public function iterate(handler: ParserNode -> Void) {
		handler(this);
		this.object.iterate(handler);
		this.key.iterate(handler);
	}
}

class ParserNodeArraySlice extends ParserNodeExpression {
	public var type = 'ParserNodeArraySlice';
    public var object: ParserNodeExpression;
    public var left: ParserNodeExpression;
    public var right: ParserNodeExpression;

	public function new(object: ParserNodeExpression, left: ParserNodeExpression, right: ParserNodeExpression) {
		super();
        this.object = object;
        this.left = left;
        this.right = right;
	}

    override public function generateCode(context: ParserNodeGenerateCodeContext) {
		return 'runtimeContext.slice(' + this.object.generateCode(context) + ', ' + this.left.generateCode(context) + ', ' + this.right.generateCode(context) + ')';
	}

	override public function iterate(handler: ParserNode -> Void) {
		handler(this);
		this.object.iterate(handler);
		this.left.iterate(handler);
		this.right.iterate(handler);
	}
}

class ParserNodeFunctionCall extends ParserNodeExpression {
	public var type = 'ParserNodeFunctionCall';
    public var functionExpr: ParserNodeExpression;
    public var arguments: ParserNodeCommaExpression;

	public function new(functionExpr: ParserNodeExpression, arguments: ParserNodeCommaExpression) {
		super();
        this.functionExpr = functionExpr;
        this.arguments = arguments;
	}

    override public function generateCode(context: ParserNodeGenerateCodeContext) {
		if (Std.is(this.functionExpr, ParserNodeArrayAccess)) {
			var arrayAccess = cast(this.functionExpr, ParserNodeArrayAccess);
			return 'runtimeContext.callContext(' + arrayAccess.object.generateCode(context) + ', ' + arrayAccess.key.generateCode(context) + ', [' + this.arguments.generateCode(context) + '], ' + Json.stringify(this.arguments.names) + ')';
		} else {
			return 'runtimeContext.call(' + this.functionExpr.generateCode(context) + ', [' + this.arguments.generateCode(context) + '], ' + Json.stringify(this.arguments.names) + ')';
		}
	}

	override public function iterate(handler: ParserNode -> Void) {
		handler(this);
		this.functionExpr.iterate(handler);
		this.arguments.iterate(handler);
	}
}

class ParserNodeFilterCall extends ParserNodeExpression {
	public var type = 'ParserNodeFilterCall';
    public var filterName: String;
    public var arguments: ParserNodeCommaExpression;

	public function new(filterName: string, arguments: ParserNodeCommaExpression) {
		super();
        this.filterName = filterName;
        this.arguments = arguments;
	}

    override public function generateCode(context: ParserNodeGenerateCodeContext) {
		return 'runtimeContext.filter(' + Json.stringify(this.filterName) + ', [' + this.arguments.generateCode(context) + '])';
	}

    override public function iterate(handler: ParserNode -> Void) {
		handler(this);
		this.arguments.iterate(handler);
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

class ParserNodeUnaryOperation extends ParserNodeExpression {
	public var type = 'ParserNodeUnaryOperation';
    public var operator: String;
    public var right: ParserNodeExpression;

	public function new(operator: string, right: ParserNodeExpression) {
		super();
        this.operator = operator;
        this.right = right;
	}

	override public function generateCode(context: ParserNodeGenerateCodeContext) {
		switch (this.operator) {
			case 'not':
				return '!(' + this.right.generateCode(context) + ')';
			default:
				return this.operator + '(' + this.right.generateCode(context) + ')';
		}
	}

	override public function iterate(handler: ParserNode -> Void) {
		handler(this);
		this.right.iterate(handler);
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

class ParserNodeBinaryOperation extends ParserNodeExpression {
	public var type = 'ParserNodeBinaryOperation';
    public var operator: String;
    public var left: ParserNodeExpression;
    public var right: ParserNodeExpression;

	public function new(operator: string, left: ParserNodeExpression, right: ParserNodeExpression) {
		super();
        this.operator = operator;
        this.left = left;
        this.right = right;
	}

    override public function iterate(handler: ParserNode -> Void) {
		handler(this);
		this.left.iterate(handler);
		this.right.iterate(handler);
	}

	override public function generateCode(context: ParserNodeGenerateCodeContext) {
		switch (this.operator) {
			case 'b-or': return '("" + ' + this.left.generateCode(context) + ' | ' + this.right.generateCode(context) + ')';
			case 'b-and': return '("" + ' + this.left.generateCode(context) + ' & ' + this.right.generateCode(context) + ')';
			case 'b-xor': return '("" + ' + this.left.generateCode(context) + ' ^ ' + this.right.generateCode(context) + ')';
			case '~': return '("" + ' + this.left.generateCode(context) + ' + ' + this.right.generateCode(context) + ')';
			case '..': return 'runtimeContext.range(' + this.left.generateCode(context) + ', ' + this.right.generateCode(context) + ')';
			case '?:': return 'runtimeContext.ternaryShortcut(' + this.left.generateCode(context) + ', ' + this.right.generateCode(context) + ')';
			case '//': return 'Math.floor(' + this.left.generateCode(context) + ' / ' + this.right.generateCode(context) + ')';
			case '**': return 'Math.pow(' + this.left.generateCode(context) + ',' + this.right.generateCode(context) + ')';
			case 'not in':
			case 'in':
				var ret = 'runtimeContext.inArray(' + this.left.generateCode(context) + ',' + this.right.generateCode(context) + ')';
				if ((this.operator == 'not in')) ret = '!(' + ret + ')';

				return ret;
			case 'is':
			case 'is not':
				var ret = '';
				var left:ParserNodeExpression = this.left;
				var right:ParserNodeExpression = this.right;

				if (Std.is(this.right, ParserNodeUnaryOperation)) {
					right = cast(this.right, ParserNodeUnaryOperation).right;
				}

				if (Std.is(right, ParserNodeFunctionCall)) {
					//throw (new Error("Not implemented ParserNodeFunctionCall"));
					ret = 'runtimeContext.test(' + cast(right, ParserNodeFunctionCall).functionExpr.generateCode(context) + ', [' + left.generateCode(context) + ',' + cast(right, ParserNodeFunctionCall).arguments.generateCode(context) + '])';
				} else if (Std.is(right, ParserNodeIdentifier)) {
					ret = 'runtimeContext.test(' + Json.stringify(cast(right, ParserNodeIdentifier).value) + ', [' + left.generateCode(context) + '])';
				} else if (Std.is(right, ParserNodeLiteral) && cast(right, ParserNodeLiteral).value == null) {
					ret = 'runtimeContext.test("null", [' + left.generateCode(context) + '])';
				} else {
					throw "ParserNodeBinaryOperation: Not implemented 'is' operator for tests with " + Json.stringify(right);
				}

				if (this.operator == 'is not') ret = '!(' + ret + ')';

				return ret;
			default:
				return (
					'(' +
						this.left.generateCode(context) +
						' ' + this.operator  + ' ' +
						this.right.generateCode(context) +
					')'
				);
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

class ParserNodeTernaryOperation extends ParserNodeExpression {
	public var type = 'ParserNodeTernaryOperation';
    public var cond: ParserNode;
    public var exprTrue: ParserNode;
    public var exprFalse: ParserNode;

	public function new(cond: ParserNode, exprTrue: ParserNode, exprFalse: ParserNode) {
		super();
        this.cond = cond;
        this.exprTrue = exprTrue;
        this.exprFalse = exprFalse;
	}

	override public function iterate(handler: ParserNode -> Void) {
		handler(this);
		this.cond.iterate(handler);
		this.exprTrue.iterate(handler);
		this.exprFalse.iterate(handler);
	}

	override public function generateCode(context: ParserNodeGenerateCodeContext) {
		return (
			'(' +
				this.cond.generateCode(context) + 
				" ? " + this.exprTrue.generateCode(context) +
				" : " + this.exprFalse.generateCode(context) +
			')'
		);
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

class ParserNodeOutputText extends ParserNode {
	public var text = '';
    public var type = 'ParserNodeOutputText';

	public function new(text: String) {
		super();
		this.text = String(text);
	}

	override public function generateCode(context: ParserNodeGenerateCodeContext) {
		if (!context.doWrite) {
			if (this.text.match(~/\S/)) throw 'A template that extends another one cannot have a body';
			return '';
		}
		return 'runtimeContext.write(' + Json.stringify(this.text) + ');';
	}
}

class ParserNodeOutputNodeExpression extends ParserNodeExpression {
	public var type = 'ParserNodeOutputNodeExpression';
    public var expression: ParserNode;

	public function new(expression: ParserNode) {
		super();
        this.expression = expression;
	}

	override public function iterate(handler: ParserNode -> Void) {
		handler(this);
		this.expression.iterate(handler);
	}

    override public function generateCode(context: ParserNodeGenerateCodeContext) {
		if (!context.doWrite) return '';
		return 'runtimeContext.write(' + this.expression.generateCode(context) + ')';
	}
}

class ParserNodeReturnStatement extends ParserNodeStatement {
	public var type = 'ParserNodeReturnStatement';
    public var expression: ParserNodeExpression;

	public function new(expression: ParserNodeExpression) {
		super();
        this.expression = expression;
	}

	override public function iterate(handler: ParserNode -> Void) {
		handler(this);
		this.expression.iterate(handler);
	}

    override public function generateCode(context: ParserNodeGenerateCodeContext) {
		return 'return ' + this.expression.generateCode(context) + ';';
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
