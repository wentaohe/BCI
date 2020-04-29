function data = load_data(base, me, pass_file)
me = me;
pass_file = pass_file;

data = struct();
data.base = base;
data.train = struct();
data.test = struct();

data.train.ecog_fid = strcat(base, '_D001');
data.train.label_fid = strcat(base, '_D002');
data.test.ecog_fid = strcat(base, '_D003');

[~, data_train_ecog_conn ] = evalc(...
    'IEEGSession(data.train.ecog_fid, me, pass_file)');
[~, data_train_label_conn ] = evalc(...
    'IEEGSession(data.train.label_fid, me, pass_file)');
[~, data_test_ecog_conn ] = evalc(...
    'IEEGSession(data.test.ecog_fid, me, pass_file)');

data.train.sr = data_train_ecog_conn.data.sampleRate;
sr_label = data_train_label_conn.data.sampleRate;
if data.train.sr ~= sr_label 
    warning('train sample rate mismatch')
end

data.train.nr_samples = data_train_ecog_conn.data.channels(1).getNrSamples + 1;

data_channels = size(data_train_ecog_conn.data.channels,2);
label_channels = size(data_train_label_conn.data.channels,2);
data.train.ecog = data_train_ecog_conn.data.getvalues(1:data.train.nr_samples,1:data_channels);
data.train.label = data_train_label_conn.data.getvalues(1:data.train.nr_samples,1:label_channels);

data.test.sr = data_test_ecog_conn.data.sampleRate;
if data.test.sr ~= data.train.sr 
    warning('test-train sample rate mismatch')
end

data_channels = size(data_test_ecog_conn.data.channels,2);
data.test.nr_samples = data_test_ecog_conn.data.channels(1).getNrSamples + 1;
data.test.ecog = data_test_ecog_conn.data.getvalues(1:data.test.nr_samples,1:data_channels); 

end
