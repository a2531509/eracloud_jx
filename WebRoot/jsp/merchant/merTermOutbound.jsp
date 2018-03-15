<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@ taglib prefix="shiro" uri="http://shiro.apache.org/tags" %>
<script type="text/javascript">
	var $cardinfo;
	$(function(){

		$cardinfo = $("#cardinfo");
		$cardinfo.datagrid({			
			url:"merchantRegister/merchantRegisterAction!queryTerOutBoundInfo.action",
			fit:true,
			pagination:false,
			rownumbers:true,
			border:false,
			striped:true,
			singleSelect:true,
			checkOnSelect:true,
			scrollbarSize:0,
			fitColumns:true,
			columns:[[
	        	{field:'END_ID',title:'终端编号',sortable:true,width:parseInt($(this).width() * 0.06)},
	        	{field:'END_NAME',title:'终端名称',sortable:true,width:parseInt($(this).width() * 0.06)},
	        	{field:'END_STATE',title:'终端状态',sortable:true,width:parseInt($(this).width() * 0.07)},
	        	{field:'OUT_DATE',title:'出库时间',sortable:true,width:parseInt($(this).width() * 0.06)},
	        	{field:'SELLER_NAME',title:'买家名称',sortable:true,width:parseInt($(this).width() * 0.05)},
	        	{field:'SELLER_MOBILE',title:'买家手机',sortable:true,width:parseInt($(this).width() * 0.05)},
	        	{field:'SELLER_LINKMAN',title:'买家联系人',sortable:true,width:parseInt($(this).width() * 0.05)},
	        	{field:'OUT_NO',title:'出库单号',sortable:true,width:parseInt($(this).width() * 0.06)},
	        	{field:'OUT_GOODS_STATE',title:'货款情况',sortable:true,width:parseInt($(this).width() * 0.1)},
	        	{field:'USER_ID',title:'操作员',sortable:true,width:parseInt($(this).width() * 0.06)},
	        	{field:'OPER_TIME',title:'操作时间',sortable:true,width:parseInt($(this).width() * 0.12)},
	        	{field:'NOTE',title:'出库备注',sortable:true,width:parseInt($(this).width() * 0.06)}
	        ]],
		 	toolbar:'#tb1',
            onLoadSuccess:function(data){
	           	 if(data.status != 0){
	           		 $.messager.alert('系统消息',data.errMsg,'error');
	           	 }
	           	 if(data.rows.length > 0 ){
		           	 $("#cardinfo").datagrid('selectRow',0);
	           	 }
            },
		 });
		$("#form").form({
			
			url :"merchantRegister/merchantRegisterAction!saveOutbound.action",
			data: $('#form').serialize(),
			onSubmit : function() {
			
				if($("#outDate").combobox("getValue")==""){
					$.messager.alert("系统消息","【出库时间】不能为空，请选择出库时间","error",function(){
						$("#outDate").combobox("showPanel");
					});
					return false;
				}	
				if($("#outGoodsState").combobox("getValue")==""){
					$.messager.alert("系统消息","【货款状态】不能为空，请选择货款状态","error",function(){
						$("#outGoodsState").combobox("showPanel");
					});
					return false;
				}
				parent.$.messager.progress({
					title : '提示',
					text : '数据处理中，请稍后....'
				});
				
				var isValid = $(this).form('validate');
				if (!isValid) {
					parent.$.messager.progress('close');
				}
				return isValid;
				//验证输入框的值
				
			},
			success:function(result) {
				parent.$.messager.progress('close');
				result = $.parseJSON(result);
				if (result.status) {
					$cardinfo.datagrid("reload");
					$dg.datagrid("reload");
				}else{
					parent.$.messager.show({
						title :  result.title,
						msg : result.message,
						timeout : 1000 * 2
					});
				}
			},
			onBeforeLoad:function(params){
				if(!params || !params.query){
					return false;
				}
			}
			
		 });
		querycardinfo();
	});
	function querycardinfo(){

		$cardinfo.datagrid('load',{
			query:true,
			"tagEnd.endId":$('#endId1').val(),
			"tagEnd.endName":$('#endName').val(),
			"merchantName":$('#sellerName').val(),
			merchantId:$("#sellerId").val()
		});
	}
	
	function outCancle(){
		var endId = $("#endId3").val();
		
		$.messager.confirm("系统消息", "确认终端 【" + endId + "】 出库撤销吗?", function(r){
			if(r){
				$.post("merchantRegister/merchantRegisterAction!saveOutboundCancel.action", {endId:endId}, function(data){
					if(!data || data.status != "0"){
						jAlert(data.errMsg, "warning");
						return;
					}
					
					jAlert("出库撤销成功");
				}, "json");
			}
		})
	}
</script>
<div class="easyui-layout" data-options="fit:true,border:false" style="background-color:rgb(245,245,245);margin-top:-4px;">
	<div data-options="region:'center',border:false" style="margin:0px;width:auto">
	  	<div id="tb1">
			<table class="tablegrid">
				<tr>
					<td class="tableleft">终端编号：</td>
					<td class="tableright"><input name="tagEnd.endId" value="${tagEnd.endId}"  class="textinput" id="endId1" type="text" /></td>
					<td class="tableleft">终端名称：</td>
					<td class="tableright"><input name="tagEnd.endName" class="textinput" id="endName" type="text" /></td>
					<td class="tableleft">商户编号：</td>
					<td class="tableright"><input id="sellerId" type="text" class="textinput" name="endOut.sellerId"/></td>
					<td class="tableleft">商户名称：</td>
					<td class="tableright"><input id="sellerName" type="text" class="textinput" name="endOut.sellerName"/></td>
					<td class="tableleft">
						<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" onclick="querycardinfo()">查询</a>
					</td>
				</tr>
			</table>
		</div>
  		<table id="cardinfo" title="商户终端基本信息"></table>
	</div>
	<div data-options="region:'south',split:false,border:true" style="height:200px; width:auto;text-align:center;border-left:none;border-bottom:none;overflow:hidden;">
		<div style="width:100%;display:none;" id="accinfodiv">
  			<h3 class="subtitle">终端信息</h3>
  			<iframe name="accinfo" id="accinfo"  width="100%" style="border:none;height:52px;padding:0px;margin:0px;"></iframe>
		</div>
		<div style="width:100%;height:100%" class="datagrid-toolbar">
			<form id="form" method="post">
				 <h3 class="subtitle">终端出库信息</h3>
				 <table class="tablegrid" style="width:100%;">
				 	<tr>
				 	    <th class="tableleft">终端编号：</th>
						<td class="tableright"><input name="tagEnd.endId"  value="${tagEnd.endId}" maxlength="10" required="required" readonly class="textinput easyui-validatebox" id="endId3" type="text"/></td>
				 		<th class="tableleft">出库时间：</th>
						<td class="tableright"><input name="endOut.outDate"  value="${endOut.outDate}"  class="easyui-datebox easyui-validatebox textinput" id="outDate" type="text"/></td>
						<th class="tableleft">单位名称：</th>
						<td class="tableright"><input name="endOut.sellerName" value="${endOut.sellerName}" maxlength="30" required="required" class="textinput easyui-validatebox" id="sellerName" type="text"/></td>
						<th class="tableleft">买家联系人：</th>
						<td class="tableright"><input name="endOut.sellerLinkman"  value="${endOut.sellerLinkman}" maxlength="10" required="required" class="textinput easyui-validatebox" id="sellerLinkman" type="text"/></td>
					</tr>
					<tr>
						<th class="tableleft">买家联系方式：</th>
						<td class="tableright"><input name="endOut.sellerMobile" value="${endOut.sellerMobile}" maxlength="11"  required="required" class="textinput easyui-validatebox" id="sellerMobile" type="text"/></td>
						<th class="tableleft">出库单号：</th>
						<td class="tableright"><input name="endOut.outNo" value="${endOut.outNo}" maxlength="30" required="required" id="outNo" type="text" class="textinput easyui-validatebox"   /></td>
					 	<th class="tableleft">货款状态：</th>
						<td class="tableright" colspan="3"><input name="endOut.outGoodsState" value="${endOut.outGoodsState}"  id=outGoodsState type="text" class="easyui-combobox textinput" data-options="panelHeight: 'auto',editable:false,
												valueField: 'label',
												textField: 'value',
												data: [{
													label: '',
													value: '请选择'
												},{
													label: '1',
													value: '1-已开具发票，款已付清'
												},{
													label: '2',
													value: '2-已开具发票，款未付清'
												},{
													label: '3',
													value: '3-未开具发票，未付款'
												},{
													label: '4',
													value: '4-未开发票，已付款 '
												},{
													label: '5',
													value: '5-维护无费用'
												},{
													label: '6',
													value: '6-租用无费用'
												},{
													label: '7',
													value: '7-自用'
												}]" ></td>
					</tr>
					<tr>
					<th class="tableleft">出库备注：</th>
					<td class="tableright" colspan="7"><textarea class="textinput easyui-validatebox" name="endOut.note"  maxlength="100" id="note" style="width:90%;height:80px;overflow:hidden;">${endOut.note}</textarea></td>
					</tr>
			  	</table>
		 	 </form>	
	 	</div>
	</div>
</div>