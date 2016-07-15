RSpec.describe ROM::SQL::Association::OneToOne, helpers: true do
  subject(:assoc) do
    ROM::SQL::Association::OneToOne.new(source, target, options)
  end

  let(:options) { {} }

  let(:users) { double(:users, primary_key: :id) }
  let(:tasks) { double(:tasks) }

  shared_examples_for 'one-to-one association' do
    describe '#combine_keys' do
      it 'returns a hash with combine keys' do
        expect(tasks).to receive(:foreign_key).with(:users).and_return(:user_id)

        expect(assoc.combine_keys(relations)).to eql(id: :user_id)
      end
    end
  end

  context 'with default names' do
    let(:source) { :users }
    let(:target) { :tasks }

    let(:relations) do
      { users: users, tasks: tasks }
    end

    it_behaves_like 'one-to-one association'

    describe '#join_keys' do
      it 'returns a hash with combine keys' do
        expect(tasks).to receive(:foreign_key).with(:users).and_return(:user_id)

        expect(assoc.join_keys(relations)).to eql(
          qualified_name(:users, :id) => qualified_name(:tasks, :user_id)
        )
      end
    end
  end

  context 'with custom relation names' do
    let(:source) { assoc_name(:users, :people) }
    let(:target) { assoc_name(:tasks, :user_tasks) }

    let(:relations) do
      { users: users, tasks: tasks }
    end

    it_behaves_like 'one-to-one association'

    describe '#join_keys' do
      it 'returns a hash with combine keys' do
        expect(tasks).to receive(:foreign_key).with(:users).and_return(:user_id)

        expect(assoc.join_keys(relations)).to eql(
          qualified_name(:people, :id) => qualified_name(:user_tasks, :user_id)
        )
      end
    end
  end
end
