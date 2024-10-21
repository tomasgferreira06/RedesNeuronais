function testNet()
    % ManuelVicente
    % TomásFerreira
    
clear all;
close all;

data = readtable('melhoresRedes/Test.csv');

inputs = table2array(data(:, 2:end-1))';  
targets = full(ind2vec(data.stroke' + 1));  

nomes_redes = {'conf16T', 'conf14T', 'conf5T', 'conf5G', 'conf12G', 'conf24G'};




 for rede = 1:numel(nomes_redes)

load(['melhoresRedes/' nomes_redes{rede} '.mat']);


if contains(nomes_redes{rede}, 'T', 'IgnoreCase', true)
            out = sim(bestNetTest.net, inputs);
        elseif contains(nomes_redes{rede}, 'G', 'IgnoreCase', true)
            out = sim(bestNetGlobal.net, inputs);
        end


 r = 0;
    for i = 1:size(out,2)               % Para cada classificacao  
      [a b] = max(out(:,i));          % b guarda a linha onde encontrou valor mais alto da saida obtida
      [c d] = max(targets(:,i));      % d guarda a linha onde encontrou valor mais alto da saida desejada
      if b == d                       % se estao na mesma linha, a classificacao foi correta (incrementa 1)
          r = r+1;
      end
    end
    globalAccuracy = r / size(out,2) * 100;

    fprintf('Precisão da %s: %f\n', nomes_redes{rede},globalAccuracy);

 end

end