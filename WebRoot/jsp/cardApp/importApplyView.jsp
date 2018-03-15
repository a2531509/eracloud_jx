<%@ page language="java" import="java.util.*" pageEncoding="utf-8"%>
<script type="text/javascript">
	function fileUploadApply() {
		var filePath =  $("#idFile").val();
		if(dealNull(filePath).length <= 0){
			$.messager.alert("系统消息","请选择需要进行导入的文件！","error");
			return;
		}
		var matchExp = /^.{1,}(\.xls|\.xlsx)$/g;
		if(matchExp.test(filePath)){
			$.messager.confirm("确认对话框", "您确定要导入该文件进行申领吗？", function(e){
				if (e){
					$.messager.progress({
						title : "提示",
						text : "正在进行文件导入，请稍后...."
					});
					$.ajaxFileUpload({
						url : "/cardapply/cardApplyAction!toBatchViewSave.action",	//用于文件上传的服务器端请求地址 
						secureuri : false,			//一般设置为false
						fileElementId:['idFile'],		//文件上传空间的id属性  <input type="file" id="file" name="file" />
						dataType :"json",			//返回值类型 一般设置为json
						success : function(data,status) {
							$.messager.progress("close");
								$.messager.alert("消息提示",data.errMsg,"info", function(){
									$dg.datagrid("reload");
									$.modalDialog.handler.dialog("destroy");
								    $.modalDialog.handler = undefined;
								});
						},
						error : function(data,status) {
							$.messager.progress("close");
							$.messager.alert("系统消息",data.errMsg,"error");
						}
					});
				}
			});
		}else{
			$.messager.alert("系统消息","选择导入文件的格式不符合要求，请重新进行选择！","error");
		}
	}

	function checkFile(filePath){
		if (filePath == null || filePath == "") {
			$.messager.alert("系统消息", "请选择要上传的文件!", "error");
			return;
		}else {
			var fileContentType = filePath.match(/^(.*)(\.)(.{1,8})$/)[3];	//这个文件类型正则很有用 
			if (fileContentType.toLowerCase() == "xls") {
				return;
			}
			$("#idFile").attr("value", "");
			$.messager.alert("系统消息","文件格式不正确!","error");
			return;
		}
	}
	function downloadTemplate(){
		        $("body").append("<iframe id=\"downloadcsv\" style=\"display:none\"></iframe>");
				$("#downloadcsv").attr("src","/cardapply/cardApplyAction!downloadTemplate.action?template=drslTemplate");
		}
		
</script>
<div class="easyui-layout" data-options="fit:true,border:false">
	<div data-options="region:'center',border:false" title=""  style="overflow: hidden; padding: 10px;">
		<form id="form" action="" enctype="multipart/form-data">
			<fieldset>
				<legend><img src="extend/fromedit.png" style="margin-bottom: -3px;" />EXECL批量导入&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href="javascript:void(0)" onclick="downloadTemplate();">模板下载</a></legend>
				<div data-options="region:'center',border:true" title="" style="height: auto; overflow: hidden; padding: 10px; text-align: center;">
					<table>
						<tr>
							<th>请选择文件：</th>
							<td>&nbsp;<input id="idFile" style="width: 550px" name="file" onchange="javascript:checkFile(this.value);" type="file" /></td>
						</tr>
			
					</table>
				</div>
			</fieldset>
		</form>
	</div>
</div>
