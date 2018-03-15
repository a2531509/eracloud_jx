<%@ page language="java" import="java.util.*" pageEncoding="utf-8"%>
<script type="text/javascript">
	function fileUpload(uploadType) {
		if (checkFile($("#idFile").attr("value"))) {
			var files = ["idFile"];  //将上传三个文件 ID 分别为file2,file2,file3
			$.messager.confirm("确认对话框", "你确定要上传压缩包中的照片？", function(e){
				if (e){
					$.messager.progress({
						title : "提示",
						text : "数据处理中，请稍后...."
					});
					$.ajaxFileUpload({
						url : "/basicPhotoAction/basicPhotoAction!toBatchImpSave.action?uploadType=" + uploadType,	//用于文件上传的服务器端请求地址 
						secureuri : false,
						fileElementId : ["idFile"],
						dataType : "json",
						success : function(data,status) {
							$.messager.progress("close");
							$.messager.alert("消息提示",data.errMsg,"info", function(){
								$dg.datagrid("reload");
								$.modalDialog.handler.dialog("destroy");
							    $.modalDialog.handler = undefined;
							});
						},
						error : function(data,status,e) {
							$.messager.progress("close");
							$.messager.alert("系统消息",e,"error");
						}
					});
				}
			});
		}
	}

	function checkFile(filePath){
		if (filePath == null || filePath == "") {
			$.messager.alert("系统消息", "请选择要上传的压缩文件!", "error");
			return false;
		}
		return true;
	}
</script>
<div class="easyui-layout" data-options="fit:true,border:false">
	<div data-options="region:'center',border:false" title=""
		style="overflow: hidden; padding: 10px;">
		<form id="form" action="" enctype="multipart/form-data">
			<fieldset>
				<legend><img src="extend/fromedit.png" style="margin-bottom: -3px;" />批量导入</legend>
				<div data-options="region:'center',border:true" title="" style="height: auto; overflow: hidden; padding: 10px; text-align: center;">
					<table>
						<tr>
							<th>选择文件：</th>
							<td><input id="idFile" style="width: 550px" name="file" onchange="javascript:checkFile(this.value);" type="file" /></td>
						</tr>
						<tr>
							<td colspan="3"><font color="red">*请正确选择您要导入的zip压缩文件，文件大小不能超过50M。如果该客户已经存在照片，导入的照片将会覆盖该客户原先的照片*</font></td>
						</tr>
					</table>
				</div>
			</fieldset>
		</form>
	</div>
</div>
