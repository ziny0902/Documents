from rich.tree import Tree # https://github.com/willmcgugan/rich
from rich.console import Console 
import json
import sys

def table_dump( tree, table_info ) :
  for table in table_info :
    full_path = "{:20}".format( table["Name"] )
    if "line" in table :
      full_path = full_path + "{:>10}".format( table["line"] )
    else :
      full_path = full_path + "{:>10}".format( "" );
    if len( table["type"] ) > 0 :
      full_path = full_path + "{:>3}".format( table["type"] )
    child_tree = tree.add(full_path)
    if len( table["member"] ) > 0 :
      table_dump( child_tree, table["member"] )

jstr = sys.stdin.readlines()
jstr = ''.join(jstr)
table_info = json.loads( jstr )

tree = Tree(".")
table_dump( tree, table_info["member"] )
console = Console()
console.print( tree )
