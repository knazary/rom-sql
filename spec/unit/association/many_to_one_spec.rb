RSpec.describe ROM::SQL::Association::ManyToOne, helpers: true do
  subject(:assoc) do
    ROM::SQL::Association::ManyToOne.new(source, target, options)
  end

  let(:options) { {} }

  let(:users) { double(:users, primary_key: :id) }
  let(:tasks) { double(:tasks) }

  shared_examples_for 'many-to-many association' do
    describe '#combine_keys' do
      it 'returns a hash with combine keys' do
        expect(tasks).to receive(:foreign_key).with(:users).and_return(:user_id)

        expect(assoc.combine_keys(relations)).to eql(user_id: :id)
      end
    end
  end

  context 'with default names' do
    let(:source) { :tasks }
    let(:target) { :users }

    let(:relations) do
      { users: users, tasks: tasks }
    end

    it_behaves_like 'many-to-many association'

    describe '#join_keys' do
      it 'returns a hash with combine keys' do
        expect(tasks).to receive(:foreign_key).with(:users).and_return(:user_id)

        expect(assoc.join_keys(relations)).to eql(
          qualified_name(:tasks, :user_id) => qualified_name(:users, :id)
        )
      end
    end
  end

  context 'with custom relation names' do
    let(:source) { assoc_name(:tasks, :user_tasks) }
    let(:target) { assoc_name(:users, :people) }

    let(:relations) do
      { users: users, tasks: tasks }
    end

    it_behaves_like 'many-to-many association'

    describe '#join_keys' do
      it 'returns a hash with combine keys' do
        expect(tasks).to receive(:foreign_key).with(:users).and_return(:user_id)

        expect(assoc.join_keys(relations)).to eql(
          qualified_name(:user_tasks, :user_id) => qualified_name(:people, :id)
        )
      end
    end
  end
end
