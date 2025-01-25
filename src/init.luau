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
  local Normals={};
  local Faces={};
  for Linenumber,Line in ipairs(Lines) do
    local Operation, info=Line:match("(%w*) *(.*)")
    if(not(Operation and info))then
      continue
    end
    if(Operation=="#" or Operation=="")then
      continue
    elseif(Operation=="v")then
      local numbers=info:gsub(" +"," "):split(" ");
      if(#numbers>4)then
        error("vertex dimension higher than 4");
      elseif(#numbers<2)then
        error("vertex dimension lower than 2");
      end
      local x,y,z=tostring(numbers[1]),tostring(numbers[2]),tostring(numbers[3]);
      if(not x or not y or not z)then
        error("x,y,z");
      end;
      local w;

      --really no point in parsing w
      --but its dont anyways
      --any one can comment out this code.
      if(numbers[4])then
        w=tostring(numbers[4]);
        if(not w)then
          error("cannot parse w");
        end
      else
        w=1;
      end
      --]]
      table.insert(Vertices,{x,y,z,w})
    elseif(Operation=="vt")then
      local numbers=info:gsub(" +"," "):split(" ");
      if(#numbers>3)then
        error("vertextexture dimension higher than 3");
      elseif(#numbers<1)then
        error("vertextexture dimension lower than 1");
      end
      local u,v,w=tonumber(numbers[1]),tonumber(numbers[2]),tonumber(numbers[3]);
      if(not(u))then
        error("test");
      end
      if(numbers[2] and not v)then
        error("v not valid");
      end
      if(numbers[3] and not w)then
        error(string.format("w not valid Line %u",Linenumber));
      end
      table.insert(TextureCoordinates,{u,v or 0,w or 0})
      
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
      table.insert(Normals,{x,y,z})
    elseif(Operation=="f")then
      --the face operation can be done in 3 ways;
      --also when a number is negative it refers to the last element and backwards
      --weird...
      
      --create for basic faces
      local faceinfo=info:gsub(" +", " "):split(" ");
      local VertexList={};
      for c,v in ipairs(faceinfo)do
        local vertexstringdata=string.split(v,"/");
        local VertexIndex=tonumber(vertexstringdata[1]);
        if(not VertexIndex)then
          error("test");
        end
        local VertexTexturePositionIndex;
        if(vertexstringdata[2] and vertexstringdata[2]~="")then --it can also be index//normal
          VertexTexturePositionIndex=tonumber(vertexstringdata[2])
          if(not VertexTexturePositionIndex)then
            error("test");
          end
        end
        local VertexNormalIndex;
        if(vertexstringdata[3])then
          VertexNormalIndex=tonumber(vertexstringdata[3])
          if(not VertexTexturePositionIndex)then
            error("test");
          end
        end
        table.insert(VertexList,{VertexIndex,VertexTexturePositionIndex,VertexNormalIndex})
      end;
      table.insert(Faces,VertexList)
    else
      warn(string.format("Unknown Operation \"%s\"",Operation));
    end
  end
  local EditableMesh=AssetService:CreateEditableMesh();
  --createFaces rotating Clockwise;
  --will not work on concaved faces but will work for initial commit

  local VertexIndexMapId={};
  for VertexIndex,Vertex in ipairs(Vertices)do
    local VertexId=EditableMesh:AddVertex(Vector3.new(Vertex[1],Vertex[2],Vertex[3]))--could of been defined early in the v thing but meh
    VertexIndexMapId[VertexIndex]=VertexId;
  end
  local TextureCoordsIndexMapId={};
  for TextureCoordsIndex,TextureCoords in ipairs(TextureCoordinates)do
    local TextureCoordId=EditableMesh:AddUV(Vector2.new(TextureCoords[1],TextureCoords[2]))--could of been defined early in the v thing but meh
    TextureCoordsIndexMapId[TextureCoordsIndex]=TextureCoordId;
  end
  print(TextureCoordsIndexMapId);
  print(TextureCoordinates);
  local NormalsIndexMapId={};
  for NormalIndex,Normal in ipairs(Normals)do
    local NormalId=EditableMesh:AddNormal(Vector3.new(Normal[1],Normal[2],Normal[3]))--could of been defined early in the v thing but meh
    NormalsIndexMapId[NormalIndex]=NormalId;
  end
  for FaceIndex,VertexList in ipairs(Faces)do
    local FirstVerticeIndex=VertexList[1][1];
    local FirstVertice=VertexIndexMapId[FirstVerticeIndex];
    for i=2,#VertexList-1 do
      local FaceId=EditableMesh:AddTriangle(FirstVertice, VertexIndexMapId[VertexList[i][1]], VertexIndexMapId[VertexList[i+1][1]])
      if(VertexList[1][2])then
        EditableMesh:SetFaceUVs(FaceId, {TextureCoordsIndexMapId[VertexList[1][2]],TextureCoordsIndexMapId[VertexList[i][2]], TextureCoordsIndexMapId[VertexList[i+1][2]]})
        print({TextureCoordsIndexMapId[VertexList[1][2]],TextureCoordsIndexMapId[VertexList[i][2]], TextureCoordsIndexMapId[VertexList[i+1][2]]})
        print({VertexList[1][2],VertexList[i][2],VertexList[i+1][2]})
      end
      if(VertexList[1][3])then
        EditableMesh:SetFaceNormals(FaceId, {NormalsIndexMapId[VertexList[1][3]],NormalsIndexMapId[VertexList[i][3]], NormalsIndexMapId[VertexList[i+1][3]]})
      end
      
    end;
  end
  
  return EditableMesh;
end

return module;
