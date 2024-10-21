function start()
% Funcao rn7b_start: cria, treina e testa uma RN feedforward com dados do CSV

% Limpar
clear all;
close all;

accuracy_total = 0;
mse_error_total = 0;
executionTime_total = 0;

% Carregar dados
data = readtable('Start.csv');

% Preparar variáveis de entrada (todas as colunas exceto 'id' e 'stroke')
X = data{:, 2:end-1}; % Assumindo que 'id' é a primeira coluna e 'stroke' é a última
X = double(X); % Converter para double para processamento

% Preparar variável target (coluna 'stroke')
Y = data.stroke;
Y = double(Y)'; % Converter para double e transpor para combinar com a entrada

iterations=50;

for i=1:iterations

% Criar RN com 10 nós na camada escondida
net = feedforwardnet(10);

% Ajustar os parâmetros seguintes:
% Função de ativação da camada de saída: usar a default
% Função de treino: usar a default
% Número de épocas de treino: usar a default
% Todos os exemplos de input são usados no treino
 % Não dividir os dados, usar tudo para treinamento

net.layers{1}.transferFcn = 'logsig';
net.layers{2}.transferFcn = 'purelin';

net.trainFcn = 'traingdx';
net.trainParam.showWindow = 0;


net.divideFcn = '';
% Treinar a rede
[net, tr] = train(net, X', Y);

% Visualizar a rede
%view(net)

% Simular a rede e guardar o resultado na variável y
y = net(X');

% Calcular métricas de desempenho
accuracy = sum(round(y) == Y) / numel(Y);
mse_error = perform(net, Y, y);


accuracy_total = accuracy_total + accuracy;
mse_error_total = mse_error_total + mse_error;

% Mostrar resultado
fprintf('Precisão Total: %.4f%%\n', accuracy * 100);
fprintf('Erro MSE: %f\n', mse_error);

% Registrar o tempo de execução
executionTime = tr.time(end); % Tempo total de treinamento
executionTime_total = executionTime_total + executionTime;
fprintf('Tempo de Execução: %.4f segundos\n', executionTime);
end

fprintf('------------------------------------\n');
fprintf('Média Precisões:\n');
fprintf('Precisão Total Média: %f%%\n', (accuracy_total / iterations) * 100);
fprintf('Média do Erro MSE: %f\n', mse_error_total / iterations);
fprintf('Tempo de execução média: %f segundos\n', executionTime_total / iterations);


end
