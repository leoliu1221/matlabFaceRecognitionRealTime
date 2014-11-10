function [out]=load_database(n)
% We load the database the first time we run the program.
%n is the number of libraries you want to read, from s1 to sn. n >=1
%persistent loaded;
%persistent w;
loaded=[];
if(isempty(loaded))
    v=zeros(10304,10*n);
    for i=1:n
        cd(strcat('s',num2str(i)));
       % disp(i);
        for j=1:10
            %disp(j)
            a=imread(strcat(num2str(j),'.bmp'));
            v(:,(i-1)*10+j)=reshape(a,size(a,1)*size(a,2),1);
        end
        cd ..
    end
    w=uint8(v); % Convert to unsigned 8 bit numbers to save memory. 
end
%loaded=1;  % Set 'loaded' to aviod loading the database again. 
out=w;