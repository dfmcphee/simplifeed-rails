require 'test_helper'

class UploadsControllerTest < ActionController::TestCase
  setup do
    @upload = uploads(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:uploads)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create upload" do
    assert_difference('Upload.count') do
      post :create, upload: { picture_content_type: @upload.picture_content_type, picture_file_name: @upload.picture_file_name, picture_file_size: @upload.picture_file_size, picture_update_at: @upload.picture_update_at }
    end

    assert_redirected_to upload_path(assigns(:upload))
  end

  test "should show upload" do
    get :show, id: @upload
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @upload
    assert_response :success
  end

  test "should update upload" do
    put :update, id: @upload, upload: { picture_content_type: @upload.picture_content_type, picture_file_name: @upload.picture_file_name, picture_file_size: @upload.picture_file_size, picture_update_at: @upload.picture_update_at }
    assert_redirected_to upload_path(assigns(:upload))
  end

  test "should destroy upload" do
    assert_difference('Upload.count', -1) do
      delete :destroy, id: @upload
    end

    assert_redirected_to uploads_path
  end
end
