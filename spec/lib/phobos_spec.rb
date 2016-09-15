require 'spec_helper'

RSpec.describe Phobos do
  describe '.configure' do
    it 'creates the configuration obj' do
      Phobos.instance_variable_set(:@config, nil)
      Phobos.configure(phobos_config_path)
      expect(Phobos.config).to_not be_nil
      expect(Phobos.config.kafka).to_not be_nil
    end
  end

  describe '.create_kafka_client' do
    it 'returns a new kafka client already configured' do
      Phobos.configure(phobos_config_path)

      expect(Kafka)
        .to receive(:new)
        .with(hash_including(Phobos.config.kafka.to_hash))
        .and_return(:kafka_client)

      expect(Phobos.create_kafka_client).to eql :kafka_client
    end
  end

  describe '.create_exponential_backoff' do
    it 'creates a configured ExponentialBackoff' do
      expect(Phobos.create_exponential_backoff).to be_a(ExponentialBackoff)
    end
  end

  describe '.logger' do
    context 'with "config.logger.file" defined' do
      it 'writes to the logger file' do
        Phobos.silence_log = false
        Phobos.config.logger.file = 'spec/spec.log'
        Phobos.configure_logger

        Phobos.logger.info('log-to-file')
        expect(File.read('spec/spec.log')).to match /log-to-file/
        File.delete(Phobos.config.logger.file)
      end
    end
  end
end
