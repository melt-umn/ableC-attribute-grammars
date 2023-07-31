grammar edu:umn:cs:melt:exts:ableC:attributeGrammars:abstractsyntax;

aspect production adtDecl
top::ADTDecl ::= _ n::Name cs::ConstructorList
{
  production attributeNames::[String] = lookupOccurrences(top.refId, top.env);
  production attributes::[AttributeItem] = map(head, map(lookupAttribute(_, top.env), attributeNames));

  production attributeStructName::String = s"_${n.name}_attributes";
  production attributeStructItems::StructItemList =
    foldStructItem(
      zipWith(
        \ n::String a::AttributeItem ->
          structItem(
            nilAttribute(),
            ableC_BaseTypeExpr {
              inst lazy<$TypeName{typeName(a.typerep.baseTypeExpr, a.typerep.typeModifierExpr)}>
            },
            consStructDeclarator(
              structField(name(n, location=builtin), baseTypeExpr(), nilAttribute()),
              nilStructDeclarator())),
        attributeNames, attributes));
        
  production decorateFunctionName::String = s"_decorate_${n.name}";

  adtDecls <-
    if null(attributeNames)
    then nilDecl()
    else
      ableC_Decls {
        struct $name{attributeStructName} {
          $StructItemList{attributeStructItems}
        };
        static void $name{decorateFunctionName}(
            struct $name{attributeStructName} *attrs, datatype $name{n.name} top) {
          match (top) {
            $StmtClauses{cs.decorateTransform}
          }
        }
      };
}

synthesized attribute decorateTransform<a>::a;

attribute decorateTransform<StmtClauses> occurs on ConstructorList;

aspect production consConstructor
top::ConstructorList ::= c::Constructor cl::ConstructorList
{
  top.decorateTransform =
    consStmtClause(c.decorateTransform, cl.decorateTransform, location=builtin);
}

aspect production nilConstructor
top::ConstructorList ::=
{
  top.decorateTransform = failureStmtClause(location=builtin);
}

attribute decorateTransform<StmtClause> occurs on Constructor;

aspect production constructor
top::Constructor ::= n::Name ps::Parameters
{
  top.decorateTransform =
    stmtClause(
      consPattern(
        constructorPattern(n, ps.decoratePatterns, location=builtin),
        nilPattern()),
      ps.decorateTransform,
      location=builtin);
}

synthesized attribute decoratePatterns::PatternList occurs on Parameters;
attribute decorateTransform<Stmt> occurs on Parameters;

aspect production consParameters
top::Parameters ::= h::ParameterDecl t::Parameters
{
  top.decoratePatterns = consPattern(h.decoratePattern, t.decoratePatterns);
  top.decorateTransform = seqStmt(h.decorateTransform, t.decorateTransform);
}

aspect production nilParameters
top::Parameters ::= 
{
  top.decoratePatterns = nilPattern();
  top.decorateTransform = nullStmt();
}

synthesized attribute decoratePattern::Pattern occurs on ParameterDecl;
attribute decorateTransform<Stmt> occurs on ParameterDecl;

aspect production parameterDecl
top::ParameterDecl ::= storage::StorageClasses  bty::BaseTypeExpr  mty::TypeModifierExpr  n::MaybeName  attrs::Attributes
{
  top.decoratePattern = patternName(fieldName, location=builtin);
  top.decorateTransform =
    decorateExpr(
      declRefExpr(varName, location=builtin),
      declRefExpr(varName2, location=builtin),
      justExpr(ableC_Expr { trail }),
      location=builtin);
}