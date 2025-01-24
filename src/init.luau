--!native
local AssetService=game:GetService("AssetService");


local module={}
---works for initial commit but concave faces are gonna be a problem.
function module.createFace()
  
end;

function module.parse(Text:string):EditableMesh
  local Lines=Text:split("\n");
  local Vertices={};
  local TextureCoordinates={};
  local VertexNormal={};
  local Faces={};
  for Linenumber,Line in ipairs(Lines) do
    local Operation, info=Line:match("(%w*) *(.*)")
    if(not(Operation and info))then
      continue
    end
    if(Operation=="#" or(Operation=="" and info==""))then
      continue
    elseif(Operation=="v")then
      local x,y,z,w=info:match("(%-?%d+%.%d+) *(%-?%d+%.%d+) *(%-?%d+%.%d+)(.*)")
      print(info);
      w=string.match(w," *(%-?%d+%.%d+)") or "1.0";
      if(not(x and y and z and w))then
        error("test");
      end
      x=tonumber(x);
      y=tonumber(y);
      z=tonumber(z);
      w=tonumber(w);
      table.insert(Vertices,{x,y,z,w})
    elseif(Operation=="vt")then
      print(info);
      local z;
      local x,y=info:match("(%-?%d+%.%d+)(.*)")
      y,z=string.match(y," *(%-?%d+%.%d+)(.*)") or "0.0";
      z=z and string.match(z," *(%-?%d+%.%d+)") or "0.0";
      if(not(x and y and z))then
        error("test");
      end
      x=tonumber(x);
      y=tonumber(y);
      z=tonumber(z);
      table.insert(TextureCoordinates,{x,y,z})
      
    elseif(Operation=="vn")then
      --vertex normal will be unused for right now;
      local x,y,z=info:match("(%-?%d+%.%d+) *(%-?%d+%.%d+) *(%-?%d+%.%d+)")
      print(info);
      if(not(x and y and z))then
        error("test");
      end
      x=tonumber(x);
      y=tonumber(y);
      z=tonumber(z);
      table.insert(VertexNormal,{x,y,z,})
    elseif(Operation=="f")then
      --the face operation can be done in 3 ways;
      --also when a number is negative it refers to the last element and backwards
      --weird...
      
      --create for basic faces
      local info=string.split(string.gsub(info, " +", " ")," ");
      local VertexList={};
      for c,v in ipairs(info)do
        local match=string.match(v,"%-?%d+");
        print(match);
        print(v);
        local number=match and tonumber(match);
        if(not number)then
          error("test");
        end
        table.insert(VertexList,number)
      end;
      table.insert(Faces,VertexList)
    else
      warn(string.format("Unknown Operation \"%s\"",Operation));
    end
  end
  local EditableMesh=AssetService:CreateEditableMesh();
  --createFaces rotating Clockwise
  --will not work on concaved faces but will work for initial commit

  local VertexIndexMapId={};
  for VertexIndex,Vertex in ipairs(Vertices)do
    local VertexId=EditableMesh:AddVertex(Vector3.new(Vertex[1],Vertex[2],Vertex[3]))--could of been defined early in the v thing but meh
    VertexIndexMapId[VertexIndex]=VertexId;
  end
  for FaceIndex,VertexList in ipairs(Faces)do
    local FirstVerticeIndex=VertexList[1];
    local FirstVertice=VertexIndexMapId[FirstVerticeIndex];
    for i=2,#VertexList-1 do
      EditableMesh:AddTriangle(FirstVertice, VertexIndexMapId[VertexList[i]], VertexIndexMapId[VertexList[i+1]])
    end;
  end
  
  return EditableMesh;
end

return module;
