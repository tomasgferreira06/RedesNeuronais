function trainApp(app)
    % ManuelVicente
    % TomásFerreira
    close all;
    accuracy_total = 0;
    accuracy_teste = 0;
    iteracoes = app.NdeIteracoesEditField.Value;  
    bestGlobalAccuracy = 0;
    bestTestAccuracy = 0;
    testAccuracyAtBestGlobal = 0;
    globalAccuracyAtBestTest = 0;
    bestNetGlobal = struct();
    bestNetTest = struct();

    % Caminhos dos arquivos são definidos na app
    path = fullfile('melhoresRedes', [app.NomeGuardarMelhorRedeGlobalEditField.Value '.mat']);
    path2 = fullfile('melhoresRedes', [app.NomeGuardarMelhorRedeTesteEditField.Value '.mat']);

    for k = 1:iteracoes
        % Carregar o conjunto de dados do arquivo CSV
        data = readtable(app.csvFilePath);

        % Separar os atributos de entrada (features) e os rótulos (labels)
        inputs = table2array(data(:, 2:end-1))';  % Exclui a coluna 'id' e transpõe
        targets = full(ind2vec(data.stroke' + 1));  % Converte a coluna alvo 'stroke' para codificação one-hot e transpõe

        % Configuração da arquitetura da rede neural
        neuronios = [app.NdeNeuronios1CamadaEditField.Value, app.NdeNeuronios2CamadaEditField.Value];
        neuronios = neuronios(~isnan(neuronios));  % Remove NaN que podem aparecer se os campos não estiverem ativos
        net = feedforwardnet(neuronios);

 % Corrigindo a configuração das funções de ativação
        net.layers{1}.transferFcn = app.FuncaodeAtivacao1CamadaEscondidaDropDown.Value;
        if numel(net.layers) > 1
            net.layers{2}.transferFcn = app.FuncaodeAtivacao2CamadaEscondidaDropDown.Value;
        end
        net.layers{end}.transferFcn = app.FuncaodeAtivacaonaCamadadeSaidaDropDown.Value;

        % Configurações de treinamento
        net.trainFcn = app.FuncaodeTreinoEditField.Value;  % Função de treinamento
        net.trainParam.showWindow = 0;
        net.divideFcn = 'dividerand';  % Função de divisão dos dados
        net.divideParam.trainRatio = app.ValordeTreinamentoEditField.Value;
        net.divideParam.valRatio = app.ValordeValidacaoEditField.Value;
        net.divideParam.testRatio = app.ValordeTesteEditField.Value;

        % TREINAR
        [net,tr] = train(net, inputs, targets);


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
    fprintf('Precisao total (nos 150 exemplos) %f\n', globalAccuracy);
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

    % Salvar as melhores redes nos caminhos especificados
    save(path, 'bestNetGlobal');
    save(path2, 'bestNetTest');

    % Imprimir resultados finais
    % fprintf('------------------------------------\n');
    % fprintf('Média Precisões:\n');
    % fprintf('Precisão Total Média: %f\n', accuracy_total / iteracoes);
    % fprintf('Precisão Teste Média: %f\n', accuracy_teste / iteracoes);
    % fprintf('------------------------------------\n');
    % fprintf('Resultados Melhor Rede Global:\n');
    % fprintf('Precisão Global: %f\n', bestGlobalAccuracy);
    % fprintf('Precisão Teste: %f\n', testAccuracyAtBestGlobal);
    % fprintf('------------------------------------\n');
    % fprintf('Resultados Melhor Rede Teste:\n');
    % fprintf('Precisão Teste: %f\n', bestTestAccuracy);
    % fprintf('Precisão Global: %f\n', globalAccuracyAtBestTest);


 uialert(app.UIFigure, sprintf('Média Precisões:\nPrecisão Total Média: %f\nPrecisão Teste Média: %f\n\nResultados Melhor Rede Global:\nPrecisão Global: %f\nPrecisão Teste: %f\n\nResultados Melhor Rede Teste:\nPrecisão Teste: %f\nPrecisão Global: %f', ...
        accuracy_total / iteracoes, accuracy_teste / iteracoes, bestGlobalAccuracy, testAccuracyAtBestGlobal, bestTestAccuracy, globalAccuracyAtBestTest), ...
        'Resultados do Treinamento', 'Icon', 'info');


end
