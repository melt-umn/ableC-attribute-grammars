grammar edu:umn:cs:melt:exts:ableC:attributeGrammars:abstractsyntax;

abstract production synAttributeDecl
top::Decl ::= ty::BaseTypeExpr d::Declarator
{
  top.pp = pp"synthesized ${ty.pp}${ppConcat(d.pps)}";
  
  local localErrors::[Message] =
    if !top.isTopLevel
    then [err(d.sourceLocation, "Attribute declarations must be global")]
    else [];
  
  ty.givenRefId = nothing();
  d.env = addEnv(ty.defs, ty.env);
  d.baseType = ty.typerep;
  d.typeModifierIn = ty.typeModifier;
  d.isTypedef = false;
  d.givenStorageClasses = nilStorageClass();
  d.givenAttributes = nilAttribute();
}

abstract production inhAttributeDecl
top::Decl ::= ty::BaseTypeExpr d::Declarator
{
  top.pp = pp"inherited ${ty.pp}${ppConcat(d.pps)}";
  
  local localErrors::[Message] =
    if !top.isTopLevel
    then [err(d.sourceLocation, "Attribute declarations must be global")]
    else [];
  
  ty.givenRefId = nothing();
  d.env = addEnv(ty.defs, ty.env);
  d.baseType = ty.typerep;
  d.typeModifierIn = ty.typeModifier;
  d.isTypedef = false;
  d.givenStorageClasses = nilStorageClass();
  d.givenAttributes = nilAttribute();
}