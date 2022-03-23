function method = extractMeth(file)

    methodFile = importMethFile(file + "\acq.txt");

    method = array2table(zeros(1,6),"VariableNames",["time", "A", "B", "C", "D", "flowrate"]);

    method.time(1) = 0;
    method.A(1) = extractNumb(38,methodFile);
    method.B(1) = extractNumb(39,methodFile);
    method.C(1) = extractNumb(40,methodFile);
    method.D(1) = extractNumb(41,methodFile);

    method.flowrate(1) = extractNumb(15,methodFile);

    if methodFile{45, "Data"} == "Timetable"

        x = 49;
        loop = 2;
        while methodFile{x, "Data"} ~= ""
            currentMeth = extractNumb(x, methodFile);

            method.time(loop) = currentMeth(1);
            method.A(loop) = currentMeth(2);
            method.B(loop) = currentMeth(3);
            method.C(loop) = currentMeth(4);
            method.D(loop) = currentMeth(5);
            method.flowrate(loop) = currentMeth(6);

            loop = loop + 1;
            x = x+1;

        end
    end
end

function x = extractNumb(line, file)
    x = str2double(regexp(file{line, "Data"},'\d*[.]\d*', 'match'));
    if isempty(x)
        x = 0;
    end
end