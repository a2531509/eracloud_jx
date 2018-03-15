<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@include file="/layout/initpage.jsp" %>
<script type="text/javascript">
	function uploadFile() {
		var filePath =  $("#importFile").val();
		if(dealNull(filePath).length <= 0){
			$.messager.alert("系统消息","请选择需要进行导入的文件！","error");
			return;
		}
		var matchExp = /^.{1,}(\.txt|\.txt)$/g;
		if(matchExp.test(filePath)){
			$.messager.confirm("系统消息","您确定要导入该制卡返回文件吗？",function(e){
				if(e){
					$.messager.progress({text:"正在进行文件导入..."});
					commonDwr.saveRechargeCardData(dwr.util.getValue("importFile"),"",{callback:function(data){
						$.messager.progress("close");
						if(data["status"] == "0"){
							$.messager.alert("系统消息","导入成功！共导入" + data["totalNum"] + "条数据！","info");
							$("#importFile").val("");
						}else{
							$.messager.alert("系统消息",data["errMsg"],"error");
						}
					},errorHandler:function(errorMsg){
						$.messager.alert("系统消息","导入文件时出现错误，请检查文件格式是否符合并重试,或联系系统管理员！" + errorMsg,"error",function(){
							$.messager.progress("close");
						});
					}});
				}
			});
		}else{
			$.messager.alert("系统消息","选择导入文件的格式不符合要求，请重新进行选择！","error");
		}
	}
</script>
<html>
<body class="easyui-layout" data-options="fit:true">
	<div data-options="region:'north',border:false" title="" style="height:auto;overflow:hidden;">
		<div class="well well-small datagrid-toolbar" style="margin-left:0px;margin-top:2px;margin-right:0px;margin-bottom:2px;">
			<span class="badge">提示</span><span>在此你可以对<span class="label-info"><strong>充值卡制卡返回文件进行导入</strong></span>操作!</span>
		</div>
	</div>
	<div data-options="region:'center',split:false,border:false" style="height:auto;overflow:hidden;border-left:none;border-bottom:none;">
		<div class="easyui-panel" style="width:100%;height:auto;overflow:hidden;border-left:none;border-bottom:none;" title="文件导入">
			<table style="width:100%" class="datagrid-toolbar tablegrid">
				<tr>
					<td align="center" width="100%" style="padding: 2px;">文件：
						<input id="importFile" name="importFile" type="file" style="width:500px;" accept="text/plain"/>
					</td>
				</tr>
				<tr>
					<td align="center" width="100%" style="padding: 2px;">
						<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-import" plain="false" onclick="uploadFile();">上传</a>
					</td>
				</tr>
			</table>
		</div>
	</div>
</body>
</html>