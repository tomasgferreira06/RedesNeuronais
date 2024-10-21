function train()

% ManuelVicente
% TomásFerreira
clear all;
close all;
accuracy_total = 0;
accuracy_teste = 0;
iteracoes = 50;
bestGlobalAccuracy = 0; % Variável para armazenar a melhor precisão de teste
bestTestAccuracy = 0;
testAccuracyAtBestGlobal = 0;  % Armazenar precisão de teste da melhor rede global
globalAccuracyAtBestTest = 0;  % Armazenar precisão global da melhor rede de teste
bestNetGlobal = struct();
bestNetTest = struct();
path = 'melhoresRedes/conf8G.mat';
path2 = 'melhoresRedes/conf8T.mat';

for k = 1:iteracoes
   
    data = readtable('Train.csv');

    
    inputs = table2array(data(:, 2:end-1))'; 
    targets = full(ind2vec(data.stroke' + 1));  

    net = feedforwardnet(10);
    
    % Configuração da rede neural
    net.layers{1}.transferFcn = 'tansig';
    net.layers{2}.transferFcn = 'purelin';
    
    
    
    
    net.trainFcn = 'traincgb';
    net.trainParam.showWindow = 0;

    % Dividir os dados em conjuntos de treinamento, validação e teste
    net.divideFcn = 'dividerand';
    net.divideParam.trainRatio = 0.7;
    net.divideParam.valRatio = 0.15;
    net.divideParam.testRatio = 0.15;

    % TREINAR
    [net,tr] = train(net, inputs, targets);


    % SIMULAR na parte de treinamento
    out = sim(net, inputs);

    % Calcular a precisão total nos exemplos de treinamento
    r = 0;
    for i = 1:size(out,2)               % Para cada classificacao  
      [a b] = max(out(:,i));          % b guarda a linha onde encontrou valor mais alto da saida obtida
      [c d] = max(targets(:,i));      % d guarda a linha onde encontrou valor mais alto da saida desejada
      if b == d                       % se estao na mesma linha, a classificacao foi correta (incrementa 1)
          r = r+1;
      end
    end
    globalAccuracy = r / size(out,2) * 100;
    fprintf('Precisao total %f\n', globalAccuracy);
    accuracy_total = accuracy_total + globalAccuracy;


    % SIMULAR na parte de teste
    TInput = inputs(:, tr.testInd);
    TTargets = targets(:, tr.testInd);
    out_teste = sim(net, TInput);

    % Calcular a precisão no conjunto de teste
    r_teste = 0;
    for i = 1:size(tr.testInd,2)               % Para cada classificacao  
      [a b_teste] = max(out_teste(:,i));          % b_teste guarda a linha onde encontrou valor mais alto da saida obtida
      [c d_teste] = max(TTargets(:,i));      % d_teste guarda a linha onde encontrou valor mais alto da saida desejada
      if b_teste == d_teste                       % se estao na mesma linha, a classificacao foi correta (incrementa 1)
          r_teste = r_teste + 1;
      end
    end
    testAccuracy = r_teste / size(tr.testInd,2) * 100;
    fprintf('Precisao teste %f\n', testAccuracy);
    accuracy_teste = accuracy_teste + testAccuracy;

    

    if (testAccuracy > bestTestAccuracy)
        bestTestAccuracy = testAccuracy;
        globalAccuracyAtBestTest = globalAccuracy;  % Atualiza a precisão global da melhor rede de teste
        bestNetTest.net = net;
        bestNetTest.tr = tr;
    end

    if(globalAccuracy > bestGlobalAccuracy)
        bestGlobalAccuracy = globalAccuracy;
        testAccuracyAtBestGlobal = testAccuracy;
        bestNetGlobal.net = net;
        bestNetGlobal.tr = tr;
    end


end

save(path, 'bestNetGlobal');
save(path2, 'bestNetTest');


% Resultados finais
fprintf('------------------------------------\n');
fprintf('Média Precisões:\n');
fprintf('Precisão Total Média: %f\n', accuracy_total / iteracoes);
fprintf('Precisão Teste Média: %f\n', accuracy_teste / iteracoes);

fprintf('------------------------------------\n');
fprintf('Resultados Melhor Rede Global:\n');
fprintf('Precisão Global: %f\n', bestGlobalAccuracy);
fprintf('Precisão Teste: %f\n', testAccuracyAtBestGlobal);

fprintf('------------------------------------\n');
fprintf('Resultados Melhor Rede Teste:\n');
fprintf('Precisão Teste: %f\n', bestTestAccuracy);
fprintf('Precisão Global: %f\n', globalAccuracyAtBestTest);


end