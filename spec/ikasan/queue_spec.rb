require 'spec_helper'
require 'ikasan/queue'

describe Ikasan::Queue do
  let(:queue) { Ikasan::Queue.new }

  before :each do
    queue.set(room: 'studio3104', message: 'cool')
    queue << { room: 'studio3104', message: 'smart' }
    queue << { room: 'moznion', message: 'crazy' }
  end

  after :each do
    q = Array.new(1)
    while !q.empty? do
      q = queue.retrieve
    end
  end

  it '#empty?' do
    expect(queue.empty?).to be_a FalseClass
    expect(Ikasan::Queue.new.empty?).to be_a TrueClass
  end

  it '#retrieve' do
    expect(queue.retrieve).to eq([
      { room: 'studio3104', message: 'cool' },
      { room: 'moznion', message: 'crazy' },
    ])
    expect(queue.retrieve).to eq([{ room: 'studio3104', message: 'smart' }])
    expect(queue.retrieve).to eq([])
  end

  it '#unshift' do
    queue.unshift(room: 'moznion', message: 'fire!')
    expect(queue.retrieve).to eq([
      { room: 'studio3104', message: 'cool' },
      { room: 'moznion', message: 'fire!' },
    ])
  end
end
