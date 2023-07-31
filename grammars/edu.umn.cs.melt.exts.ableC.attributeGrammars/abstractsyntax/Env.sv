grammar edu:umn:cs:melt:exts:ableC:attributeGrammars:abstractsyntax;

synthesized attribute isSyn::Boolean;
synthesized attribute isInh::Boolean;

closed nonterminal AttributeItem with sourceLocation, typerep, isSyn, isInh;

aspect default production
top::AttributeItem ::=
{
  top.isSyn = false;
  top.isInh = false;
}

abstract production synAttributeItem
top::AttributeItem ::= d::Decorated Declarator
{
  top.sourceLocation = d.sourceLocation;
  top.typerep = d.typerep;
  top.isSyn = true;
}

abstract production inhAttributeItem
top::AttributeItem ::= d::Decorated Declarator
{
  top.sourceLocation = d.sourceLocation;
  top.typerep = d.typerep;
  top.isInh = true;
}

abstract production errorAttributeItem
top::AttributeItem ::= 
{
  top.typerep = errorType();
  top.isSyn = true;
  top.isInh = true;
}

synthesized attribute attributes::Scopes<AttributeItem> occurs on Env;
synthesized attribute occurrences::Scopes<[String]> occurs on Env;
synthesized attribute attributeContribs::Contribs<AttributeItem> occurs on Defs, Def;
synthesized attribute occurrenceContribs::Contribs<[String]> occurs on Defs, Def;

aspect production emptyEnv_i
top::Env ::=
{
  top.attributes = emptyScope();
  top.occurrences = emptyScope();
}
aspect production addEnv_i
top::Env ::= d::Defs  e::Decorated Env
{
  top.attributes = addGlobalScope(gd.attributeContribs, addScope(d.attributeContribs, e.attributes));
  top.occurrences = addGlobalScope(gd.occurrenceContribs, addScope(d.occurrenceContribs, e.occurrences));
}
aspect production openScopeEnv_i
top::Env ::= e::Decorated Env
{
  top.attributes = openScope(e.attributes);
  top.occurrences = openScope(e.occurrences);
}
aspect production globalEnv_i
top::Env ::= e::Decorated Env
{
  top.attributes = globalScope(e.attributes);
  top.occurrences = globalScope(e.occurrences);
}
aspect production nonGlobalEnv_i
top::Env ::= e::Decorated Env
{
  top.attributes = nonGlobalScope(e.attributes);
  top.occurrences = nonGlobalScope(e.occurrences);
}
aspect production functionEnv_i
top::Env ::= e::Decorated Env
{
  top.attributes = functionScope(e.attributes);
  top.occurrences = functionScope(e.occurrences);
}

aspect production nilDefs
top::Defs ::=
{
  top.attributeContribs = [];
  top.occurrenceContribs = [];
}
aspect production consDefs
top::Defs ::= h::Def  t::Defs
{
  top.attributeContribs = h.attributeContribs ++ t.attributeContribs;
  top.occurrenceContribs = h.occurrenceContribs ++ t.occurrenceContribs;
}

aspect default production
top::Def ::=
{
  top.attributeContribs = [];
  top.occurrenceContribs = [];
}

abstract production attributeDef
top::Def ::= s::String  t::AttributeItem
{
  top.attributeContribs = [pair(s, t)];
}

abstract production occursDef
top::Def ::= refId::String  attrs::[String]
{
  top.occurrenceContribs = [pair(refId, attrs)];
}

function lookupAttribute
[AttributeItem] ::= n::String  e::Decorated Env
{
  return lookupScope(n, e.attributes);
}

function lookupOccurrences
[String] ::= refId::String  e::Decorated Env
{
  return unionsBy(stringEq, lookupScope(refId, e.occurrences));
}

synthesized attribute attributeItem::Decorated AttributeItem occurs on Name;
synthesized attribute attributeLookupCheck::[Message] occurs on Name;
synthesized attribute attributeRedeclarationCheck::[Message] occurs on Name;

aspect production name
top::Name ::= n::String
{
  local attributes::[AttributeItem] = lookupAttribute(n, top.env);
  top.attributeLookupCheck =
    case attributes of
    | [] -> [err(top.location, "Undeclared attribute " ++ n)]
    | _ :: _ -> []
    end;
  
  top.attributeRedeclarationCheck =
    case attributes of
    | [] -> []
    | v :: _ ->
        [err(top.location, 
          "Redeclaration of " ++ n ++ ". Original (from " ++
          v.sourceLocation.unparse ++ ")")]
    end;
  
  local attr::AttributeItem = if null(attributes) then errorAttributeItem() else head(attributes);
  top.attributeItem = attr;
}
