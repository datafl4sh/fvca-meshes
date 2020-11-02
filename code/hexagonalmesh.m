function [] = hexagonalmesh (i)
% Le maillage cartesien de base est de taille 2^(i+2)*2^(i+2)

% Creation du fichier de maillage
file_nbr = int2str(i);
file_name = strcat('xxx_hexagonal_',file_nbr,'.typ1');
fid = fopen(file_name,'w');

% Coordonnees des noeuds
size = 2^(i+2);
h = 1/size;
nodes_nbr = (size/2+1)^2 + (size/2)^2;
nodes_coor = [0. 0.];
% Boucle sur les size+1 lignes horizontales du maillage cartesien (de bas
% en haut)
for k=1:(size+1)
    if mod(k,2)==1
        j = 0;
        while j<size
            nodes_coor = [nodes_coor; (j+3)*h (k-1)*h; (j+4)*h (k-1)*h];
            j = j+4;
        end
    else
        j = 0;
        while j<size
            nodes_coor = [nodes_coor; (j+1)*h (k-1)*h; (j+2)*h (k-1)*h];
            j = j+4;
        end
        nodes_coor = [nodes_coor; 0. k*h];
    end
end

fprintf(fid,'%s\n','vertices');
fprintf(fid,'%i\n',nodes_nbr);
for k=1:nodes_nbr
    fprintf(fid,'%g\t %g\n',nodes_coor(k,:));
end

% Triangles
triangles_nbr = size/2;
% Boucle sur les triangles
for k=1:triangles_nbr
    offset = (k-1)*(size+1);
    triangles_id(k,:) = offset + [1 size/2+2 size+2];
end

fprintf(fid,'%s\n','triangles');
fprintf(fid,'%i\n',triangles_nbr);
for k=1:triangles_nbr
    fprintf(fid,'%i\t %i\t %i\n',triangles_id(k,:));
end

% Quadrangles
quadrangles_nbr = size/2;
% Boucle sur les quadrangles du bas de grille
for k=1:quadrangles_nbr/2
    offset = 2*(k-1);
    quadrangles_id(k,:) = offset + [1 2 size/2+3 size/2+2];
end
% Boucle sur les quadrangles du haut de grille
for k=1:quadrangles_nbr/2
    offset = nodes_nbr-(size+1)+2*(k-1);
    quadrangles_id(quadrangles_nbr/2+k,:) = offset + [1 2 size/2+2 size/2+1];
end

fprintf(fid,'%s\n','quadrangles');
fprintf(fid,'%i\n',quadrangles_nbr);
for k=1:quadrangles_nbr
    fprintf(fid,'%i\t %i\t %i\t %i\n',quadrangles_id(k,:));
end

% Pentagones
pentagons_nbr = size/2;
% Boucle sur les pentagones
for k=1:pentagons_nbr
    offset = (k-1)*(size+1);
    pentagons_id(k,:) = offset + [size/2 size/2+1 3*size/2+2 3*size/2+1 size+1];
end

fprintf(fid,'%s\n','pentagons');
fprintf(fid,'%i\n',pentagons_nbr);
for k=1:pentagons_nbr
    fprintf(fid,'%i\t %i\t %i\t %i\t %i\n',pentagons_id(k,:));
end

% Hexagones ('up' et 'down')
hexagons_nbr = (size/4-1)*size/2 + size/4*(size/2-1);
% Boucle sur les hexagones 'up'
for j=1:size/2
    for k=1:(size/4-1)
        offset = (j-1)*(size+1)+2*(k-1);
        hexagons_id((j-1)*(size/4-1)+k,:) = offset + [2 3 size/2+4 size+4 size+3 size/2+3];
    end
end
% Boucle sur les hexagones 'down'
for j=1:(size/2-1)
    for k=1:size/4
        offset = (j-1)*(size+1)+2*(k-1);
        hexagons_id((size/4-1)*size/2+(j-1)*size/4+k,:) = offset + [size/2+2 size/2+3 size+3 3*size/2+4 3*size/2+3 size+2];
    end
end

fprintf(fid,'%s\n','hexagons');
fprintf(fid,'%i\n',hexagons_nbr);
for k=1:hexagons_nbr
    fprintf(fid,'%i\t %i\t %i\t %i\t %i\t %i\n',hexagons_id(k,:));
end

% Faces
for k=1:triangles_nbr
    for j=1:3
        faces_id_temp(3*(k-1)+j,:) = [triangles_id(k,j) triangles_id(k,mod(j,3)+1) k];
    end
end
offset_f = 3*triangles_nbr;
offset_e = triangles_nbr;
for k=1:quadrangles_nbr
    for j=1:4
        faces_id_temp(offset_f+4*(k-1)+j,:) = [quadrangles_id(k,j) quadrangles_id(k,mod(j,4)+1) offset_e+k];
    end
end
offset_f = offset_f + 4*quadrangles_nbr;
offset_e = offset_e + quadrangles_nbr;
for k=1:pentagons_nbr
    for j=1:5
        faces_id_temp(offset_f+5*(k-1)+j,:) = [pentagons_id(k,j) pentagons_id(k,mod(j,5)+1) offset_e+k];
    end
end
offset_f = offset_f + 5*pentagons_nbr;
offset_e = offset_e + pentagons_nbr;
for k=1:hexagons_nbr
    for j=1:6
        faces_id_temp(offset_f+6*(k-1)+j,:) = [hexagons_id(k,j) hexagons_id(k,mod(j,6)+1) offset_e+k];
    end
end
offset_f = offset_f + 6*hexagons_nbr;

faces_nbr = 0;
inn_faces_nbr = 0;
bnd_faces_nbr = 0;
list_id = [1:1:offset_f];
while (length(find(list_id))>0)
    if length(find(list_id))==1
        k = find(list_id);
        faces_nbr = faces_nbr + 1;
        bnd_faces_nbr = bnd_faces_nbr + 1;
	    min_id = min(faces_id_temp(k,1),faces_id_temp(k,2));
        max_id = max(faces_id_temp(k,1),faces_id_temp(k,2));
        faces_id(faces_nbr,:) = [min_id max_id faces_id_temp(k,3) 0];
        faces_id_bnd(bnd_faces_nbr,:) = [min_id max_id];
        list_id(k) = 0;
    else
        k = find(list_id);
        ka = k(1);
        bool = 0;
        j = 2;
        while j<(length(k)+1)
            kb = k(j);
            if (faces_id_temp(kb,1) == faces_id_temp(ka,2) && faces_id_temp(kb,2) == faces_id_temp(ka,1))
                faces_nbr = faces_nbr + 1;
                inn_faces_nbr = inn_faces_nbr + 1;
                min_id = min(faces_id_temp(ka,1),faces_id_temp(ka,2));
                max_id = max(faces_id_temp(ka,1),faces_id_temp(ka,2));
                faces_id(faces_nbr,:) = [min_id max_id faces_id_temp(ka,3) faces_id_temp(kb,3)];
                list_id(ka) = 0;
                list_id(kb) = 0;
                bool = 1;
                j = length(k)+1;
            else
                j = j+1;
            end
        end
        if (bool==0)
            faces_nbr = faces_nbr + 1;
            bnd_faces_nbr = bnd_faces_nbr + 1;
            min_id = min(faces_id_temp(ka,1),faces_id_temp(ka,2));
            max_id = max(faces_id_temp(ka,1),faces_id_temp(ka,2));
            faces_id(faces_nbr,:) = [min_id max_id faces_id_temp(ka,3) 0];
            faces_id_bnd(bnd_faces_nbr,:) = [min_id max_id];
            list_id(ka) = 0;
        end
    end
end

fprintf(fid,'%s\n','edges of the boundary');
fprintf(fid,'%i\n',bnd_faces_nbr);
for k=1:bnd_faces_nbr
    fprintf(fid,'%i\t %i\n',faces_id_bnd(k,:));
end
fprintf(fid,'%s\n','all edges');
fprintf(fid,'%i\n',faces_nbr);
for k=1:faces_nbr
    fprintf(fid,'%i\t %i\t %i\t %i\n',faces_id(k,:));
end

fclose(fid);

end
