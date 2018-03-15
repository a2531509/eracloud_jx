<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@ taglib prefix="shiro" uri="http://shiro.apache.org/tags" %>
	<script type="text/javascript">
		var $dgview;
		var $gridview;
		var $girdtest;
		var taskId="";
		var readCardFlag = true;
		$(function(){
			
			createCertType("certTypeTemp");
			$dgview = $("#dgview");
			$gridview=$dgview.datagrid({
				url:"cardService/cardRecoverRegisterAction!queryTempData.action",
				pagination:true,
				rownumbers:true,
				border:true,
				striped:true,
				fit:true,
				fitColumns:true,
				//scrollbarSize:0,
				singleSelect:false,
				pageSize:20,
				columns:[[ 
					{field:'ID',checkbox:true},
					{field:'CERT_NO',title:'证件号码',sortable:true,width:parseInt($(this).width()*0.015)},
					{field:'NAME',title:'姓名',sortable:true,width:parseInt($(this).width()*0.01)},
					{field:'CARD_NO',title:'卡号',sortable:true,width:parseInt($(this).width()*0.015)},
					{field:'APPLY_DATE',title:'申领日期',sortable:true,width:parseInt($(this).width()*0.015)},
					{field:'BRANCH',title:'申领网点',sortable:true,width:parseInt($(this).width()*0.015)},
					{field:'USER_NAME',title:'申领柜员',sortable:true,width:parseInt($(this).width()*0.015)},
					{field:'INITIAL_STATUS',title:'申领状态',sortable:true,width:parseInt($(this).width()*0.01)}
				]],toolbar:'#tbview',
				onLoadSuccess:function(data){
		            	  $("input[type=checkbox]").each(function(){
		        				this.checked = false;
		        		  });
		            	  if(data.status != 0){
		            		 $.messager.alert('系统消息',data.errMsg,'error');
		            	  }
	            	}
			});
		});
		
		 function deleteData(){
			 var rows = $dgview.datagrid('getChecked');
			 var dataSeqs="";
			 if(rows.length > 0){
				 //组转勾选的参数
				 for(var i=0;i<rows.length;i++){
					 dataSeqs = dataSeqs+rows[i].CARD_NO+",";
				 }
				 $.messager.confirm('系统消息','你确定删除吗？', function(r){
		     			if (r){
		     				 $.post("cardService/cardRecoverRegisterAction!deleteCardRecTemp.action", {cardNoTemp:dataSeqs,taskId:rows[0].TASK_ID},
		     						   function(data){
		     						     	if(data.status == '0'){
		     						     		$dgview.datagrid('reload');
		     						     		$.messager.alert('系统消息','删除成功','info');
		     						     	}else{
		     						     		$.messager.alert('系统消息',data.errMsg,'error');
		     						     	}
		     						   }, "json");
		     			}
		     		});
			 }else{
				 $.messager.alert('系统消息','请选择记录进行删除','info');
			 }
		 }
		
		
		function readCardImport(){
			var cardmsg;
			try {
				cardmsg = getcardinfo();
				
			 	$.messager.progress({title : '提示',text : '数据处理中，请稍后....'});

				$.post('cardService/cardRecoverRegisterAction!saveCardTemp.action',{cardNoTemp:cardmsg['card_No']},function(data,status){
					$.messager.progress('close');
					if(data.status == '0'){
						$.messager.alert("系统消息","添加成功", "info");
						$dgview.datagrid('load');
					}else{
						$.messager.alert("系统消息",data.errMsg, "error");
					}
			 	},"json");
			} catch (e) {
				 $.messager.alert('提示消息','请重新放卡或换卡读入','info');
			}
		}
		
		function saveCardRecoverRegInfo(){
			var rows = $dgview.datagrid('getChecked');
			var dataSeqs="";
			if(rows.length > 0){
				 
				for(var i=0;i<rows.length;i++){
					dataSeqs = dataSeqs+rows[i].CARD_NO+",";
				}
				
				$.messager.prompt('系统消息','请输入盒号', function(r){
					 if(r){
						 var reg =/^\d{1,10}$/;
						 
						 if(!reg.test(r)){
							 $.messager.alert('消息提示',"请输入数字",'info');
							 return;
						 }
						 
						 $.post("cardService/cardRecoverRegisterAction!saveCardRecoverReg.action", {cardNoTemp:dataSeqs,boxNo:r},
	     						   function(data){
							 if(data.status == '0'){
									var msg = "卡片回收登记完成.";
			        				if(data.failList){
			        					msg += "<br>" + data.msg + "<br>";
			        					
			        					var array = eval(data.failList);
			        					
			        					for(var i = 0; i< array.length; i++){
			        						msg += "<br>[卡号:" + array[i].cardNo + ", " + array[i].errMsg + "]";
			        					}
			        				}
			        				$.messager.alert('消息提示',msg,'info');
			        				$.modalDialog.handler.dialog('destroy');
								    $.modalDialog.handler = undefined;
			            		}else{
			            			$.messager.alert('消息提示',data.errMsg, 'error');
			            		}
	     					}, "json");
					 }
				 });
			 } else {
				 $.messager.alert('系统消息','请选择记录进行保存','info');
			 }
		}
		
		function excelImport(){
			$.ajaxFileUpload({  
                url:"cardService/cardRecoverRegisterAction!saveCardTempFromExcel.action",
                secureuri:false,  
                fileElementId:['excel'],
                dataType:"json",
                success: function(data, status){
                	if(data.status == '0'){
                		var msg = "添加完成.";
            			
            			if(data.failList){
            				msg += "<br>" + data.msg + "<br>";
        					
        					var array = eval(data.failList);
        					
        					for(var i = 0; i< array.length; i++){
        						msg += "<br>[卡号:" + array[i].cardNo + ", " + array[i].errMsg + "]";
        					}
        				}
            			
            			$.messager.alert("消息提示",msg,"info");
            			
            			$dgview.datagrid('load');
                	}else{
                		$.messager.alert('消息提示',data.errMsg,'error');
                	}
                },
                error: function (data, status, e){
                	$.messager.alert("消息提示", "网络连接异常, " + status, "error");
                	$dgview.datagrid('load');
                }
            });
		}
		
		function queryCardRecTemp(){
			$dgview.datagrid("load", {
				certTypeTemp:$("#certTypeTemp").combobox('getValue'), 
				certNoTemp:$('#certNoTemp').val(), 
				nameTemp:$("#nameTemp").val(),
				cardNoTemp:$('#cardNoTemp').val()
			});
		}
			
	</script>
  <div class="easyui-layout" data-options="fit:true">
	  <div data-options="region:'center',split:false,border:false" style="height:auto;overflow:hidden;">
		  <div id="tbview" style="padding:2px 0">
				<table cellpadding="0" cellspacing="0" class="tablegrid">
					<tr>
						<td style="padding:0 3px;" class="tableleft">证件类型：</td>
						<td style="padding:0 3px;" class="tableright"><input type="text" name="certTypeTemp" id="certTypeTemp" class="textinput" style="width:174px;cursor:pointer;"/></td>
						<td style="padding:0 3px;" class="tableleft">证件号码：</td>
						<td style="padding:0 3px;" class="tableright"><input type="text" name="certNoTemp" id="certNoTemp" class="textinput"/>
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton2" name="subbutton" onclick="queryCardRecTemp()">查询</a>
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-readCard'" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton1" name="subbutton" onclick="readCardImport()">读卡录入</a>
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-remove'" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton4" name="subbutton" onclick="deleteData()">删除数剧</a>
						</td>
					</tr>
					<tr>
						<td style="padding:0 3px;" class="tableleft">姓名：</td>
						<td style="padding:0 3px;" class="tableright"><input type="text" name="nameTemp" id="nameTemp" class="textinput"/></td>
						<td style="padding:0 3px;" class="tableleft">卡号：</td>
						<td style="padding:0 3px;" class="tableright"><input type="text" name="cardNoTemp" id="cardNoTemp" class="textinput"/>
							
							<input id="excel"  name="file" type="file" class="textinput"/>
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-excel'" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton3" name="subbutton" onclick="excelImport()">EXCEL录入</a>
						</td>
					</tr>
				</table>
			</div>
		    <table id="dgview"></table>
	  </div>
  </div>
