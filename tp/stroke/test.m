function test(app)
    % ManuelVicente
    % TomásFerreira
    close all;
 
        
      data = readtable(app.csvFilePath);

       
        inputs = table2array(data(:, 2:end-1))'; 
        targets = full(ind2vec(data.stroke' + 1));  


        load([app.NomedaRedeEditField.Value '.mat']);


if contains(app.NomedaRedeEditField.Value, 'T', 'IgnoreCase', true)
            out = sim(bestNetTest.net, inputs);
        elseif contains(app.NomedaRedeEditField.Value, 'G', 'IgnoreCase', true) 
            out = sim(bestNetGlobal.net, inputs);
        end


 r = 0;
    for i = 1:size(out,2)               
      [a b] = max(out(:,i));          
      [c d] = max(targets(:,i));     
      if b == d                     
          r = r+1;
      end
    end
    globalAccuracy = r / size(out,2) * 100;

    fprintf('Precisão: %f\n', globalAccuracy);
    uialert(app.UIFigure, ...
    sprintf('Precisão da Rede: %f\n', globalAccuracy), ...
    'Precisão do Modelo', ...  
    'Icon', 'info');  



end
