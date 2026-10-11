package better.playable.lawn;

#if macro
import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.ExprTools;

class LawnMacro {
    public static function includeSubclasses():Array<Field> {
        Compiler.include("better.playable.lawn", true);
        return Context.getBuildFields();
    }

    public static function build():Array<Field> {
        var fields = Context.getBuildFields();
        var localClass = Context.getLocalClass().get();

        if (localClass.isInterface || localClass.name == "Lawn") {
            return fields;
        }

        var id:Null<String> = null;
        for (field in fields) {
            if (field.name != "new") continue;
            switch (field.kind) {
                case FFun(fn):
                    ExprTools.iter(fn.expr, function(expr) {
                        if (id != null) return;
                        switch (expr.expr) {
                            case ECall({expr: EConst(CIdent("super"))}, args):
                                if (args.length > 0) {
                                    switch (args[0].expr) {
                                        case EConst(CString(value, _)): id = value;
                                        default:
                                    }
                                }
                            default:
                        }
                    });
                default:
            }
        }

        if (id == null) {
            Context.error('Lawn subclasses must call super("id") with a string literal.', Context.currentPos());
        }

        var className = localClass.name;
        var classPack = localClass.pack.join(".");
        var fullPath = classPack.length > 0 ? classPack + "." + className : className;
        var registerExpr = macro better.playable.lawn.LawnRegistry.register($v{id}, $p{fullPath.split(".")});

        fields.push({
            name: "__lawnRegistration",
            access: [APrivate, AStatic],
            kind: FVar(macro:Class<better.playable.lawn.Lawn>, registerExpr),
            pos: Context.currentPos()
        });

        return fields;
    }

    public static function rewriteFactory():Array<Field> {
        var fields = Context.getBuildFields();
        function rewrite(expr:Expr):Expr {
            return switch (expr.expr) {
                case ENew(type, args) if (type.name == "Lawn" && (type.pack.length == 0 || type.pack.join(".") == "better.playable.lawn")):
                    macro better.playable.lawn.LawnRegistry.create($a{args});
                default:
                    ExprTools.map(expr, rewrite);
            }
        }

        for (field in fields) {
            switch (field.kind) {
                case FFun(fn) if (fn.expr != null):
                    fn.expr = rewrite(fn.expr);
                default:
            }
        }
        return fields;
    }
}
#end